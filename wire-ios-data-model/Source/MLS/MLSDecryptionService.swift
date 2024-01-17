//
// Wire
// Copyright (C) 2023 Wire Swiss GmbH
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
//

import Foundation
import WireCoreCrypto
import Combine
import WireSystem

// sourcery: AutoMockable
public protocol MLSDecryptionServiceInterface {

    func onEpochChanged() -> AnyPublisher<MLSGroupID, Never>

    func decrypt(
        message: String,
        for groupID: MLSGroupID,
        subconversationType: SubgroupType?
    ) async throws -> [MLSDecryptResult]

}

public enum MLSDecryptResult: Equatable {

    case message(_ messageData: Data, _ senderClientID: String?)
    case proposal(_ commitDelay: UInt64)

}

protocol DecryptedMessageBundle {

    var message: Data? { get }
    var proposals: [WireCoreCrypto.ProposalBundle] { get }
    var isActive: Bool { get }
    var commitDelay: UInt64? { get }
    var senderClientId: WireCoreCrypto.ClientId? { get }
    var hasEpochChanged: Bool { get }
    var identity: WireCoreCrypto.WireIdentity? { get }

}

extension DecryptedMessage: DecryptedMessageBundle { }
extension BufferedDecryptedMessage: DecryptedMessageBundle { }

public final class MLSDecryptionService: MLSDecryptionServiceInterface {

    // MARK: - Properties

    private let mlsActionExecutor: MLSActionExecutorProtocol
    private weak var context: NSManagedObjectContext?
    private let subconverationGroupIDRepository: SubconversationGroupIDRepositoryInterface

    private let onEpochChangedSubject = PassthroughSubject<MLSGroupID, Never>()

    public func onEpochChanged() -> AnyPublisher<MLSGroupID, Never> {
        return onEpochChangedSubject.eraseToAnyPublisher()
    }

    // MARK: - Life cycle

    public init(
        context: NSManagedObjectContext,
        mlsActionExecutor: MLSActionExecutorProtocol,
        subconversationGroupIDRepository: SubconversationGroupIDRepositoryInterface = SubconversationGroupIDRepository()
    ) {
        self.mlsActionExecutor = mlsActionExecutor
        self.context = context
        self.subconverationGroupIDRepository = subconversationGroupIDRepository
    }

    // MARK: - Message decryption

    public enum MLSMessageDecryptionError: Error {

        case failedToConvertMessageToBytes
        case failedToDecryptMessage
        case failedToDecodeSenderClientID
        case wrongEpoch

    }

    /// Decrypts an MLS message for the given group
    ///
    /// - Parameters:
    ///   - message: a base64 encoded encrypted message
    ///   - groupID: the id of the MLS group
    ///   - subconversationType: the type of subconversation (if it exists)  to which this message belongs
    ///
    /// - Throws: `MLSMessageDecryptionError` if the message could not be decrypted.
    ///
    /// - Returns:
    ///   The data representing the decrypted message bytes.
    ///   May be nil if the message was a handshake message, in which case it is safe to ignore.

    public func decrypt(
        message: String,
        for groupID: MLSGroupID,
        subconversationType: SubgroupType?
    ) async throws -> [MLSDecryptResult] {
        WireLogger.mls.debug("decrypting message for group (\(groupID.safeForLoggingDescription)) and subconversation type (\(String(describing: subconversationType)))")

        guard let messageData = message.base64DecodedData else {
            throw MLSMessageDecryptionError.failedToConvertMessageToBytes
        }

        var groupID = groupID
        var debugInfo = "parentID: \(groupID)"
        if
            let type = subconversationType,
            let subconversationGroupID = await subconverationGroupIDRepository.fetchSubconversationGroupID(
                forType: type,
                parentGroupID: groupID
            )
        {
            groupID = subconversationGroupID
            debugInfo.append("; subconversationGroupID: \(subconversationGroupID)")
        }

        do {
            let decryptedMessage = try await mlsActionExecutor.decryptMessage(messageData, in: groupID)

            if decryptedMessage.hasEpochChanged {
                onEpochChangedSubject.send(groupID)
            }

            var results = try decryptedMessage.bufferedMessages?.compactMap({ try decryptResult(from: $0) }) ?? []

            if let result = try decryptResult(from: decryptedMessage) {
                results.append(result)
            }

            return results
        } catch {
            WireLogger.mls.error("failed to decrypt message for group (\(groupID.safeForLoggingDescription)) and subconversation type (\(String(describing: subconversationType))): \(String(describing: error)) | \(debugInfo)")

            switch error {
            // Received messages targeting a future epoch, we might have lost messages.
            case CryptoError.WrongEpoch: throw MLSMessageDecryptionError.wrongEpoch

            // Message arrive in future epoch, it has been buffered and will be consumed later.
            case CryptoError.BufferedFutureMessage: return []

            // Received already sent or received message, can safely be ignored.
            case CryptoError.DuplicateMessage: return []

            // Received self commit, any pending self commit has now been merged
            case CryptoError.SelfCommitIgnored: return []

            // Message arrive in an unmerged group, it has been buffered and will be consumed later.
            case CryptoError.UnmergedPendingGroup: return []
            default:
                throw MLSMessageDecryptionError.failedToDecryptMessage
            }
        }
    }

    private func decryptResult(from messageBundle: some DecryptedMessageBundle) throws -> MLSDecryptResult? {
        if let commitDelay = messageBundle.commitDelay {
            return MLSDecryptResult.proposal(commitDelay)
        }

        if let message = messageBundle.message {
            guard let clientId = messageBundle.senderClientId else {
                // We are guaranteed to have a senderClientId with messages
                throw MLSMessageDecryptionError.failedToDecodeSenderClientID
            }

            return MLSDecryptResult.message(
                message,
                try senderClientId(from: clientId).clientID
            )
        }

        return nil
    }

    private func senderClientId(from data: ClientId) throws -> MLSClientID {
        guard let clientID = MLSClientID(data: data) else {
            throw MLSMessageDecryptionError.failedToDecodeSenderClientID
        }
        return clientID
    }
}
