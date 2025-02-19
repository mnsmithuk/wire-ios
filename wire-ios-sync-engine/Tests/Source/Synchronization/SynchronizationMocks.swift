//
// Wire
// Copyright (C) 2024 Wire Swiss GmbH
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

import AddressBook
import avs
import Foundation
import WireCryptobox
import WireDataModel
@testable import WireSyncEngine

@objcMembers
public class MockApplicationStatus: NSObject, ApplicationStatus, ClientRegistrationDelegate, ZMRequestCancellation {

    public var taskCancellationDelegate: ZMRequestCancellation { return self }
    public var clientRegistrationDelegate: ClientRegistrationDelegate { return self }

    public var mockSynchronizationState = SynchronizationState.unauthenticated
    public var synchronizationState: SynchronizationState {
        return mockSynchronizationState
    }

    public var mockOperationState = OperationState.foreground
    public var operationState: OperationState {
        return mockOperationState
    }

    public var requestCancellation: ZMRequestCancellation {
        return self
    }

    // MARK: ZMRequestCancellation
    public var cancelledIdentifiers = [ZMTaskIdentifier]()

    public func cancelTask(with identifier: ZMTaskIdentifier) {
        cancelledIdentifiers.append(identifier)
    }

    // MARK: ClientRegistrationDelegate
    public var deletionCalls: Int = 0

    /// Notify that the current client was deleted remotely
    public func didDetectCurrentClientDeletion() {
        deletionCalls += 1
    }

    /// Returns true if the client is registered
    public var clientIsReadyForRequests: Bool {
        return true
    }

    public var didRequestResyncResources = false
    public func requestResyncResources() {
        didRequestResyncResources = true
    }

}

class MockAuthenticationStatus: ZMAuthenticationStatus {

    var mockPhase: ZMAuthenticationPhase

    init(delegate: ZMAuthenticationStatusDelegate,
         phase: ZMAuthenticationPhase = .authenticated,
         userInfoParser: UserInfoParser) {
        self.mockPhase = phase
        super.init(delegate: delegate,
                   groupQueue: DispatchGroupQueue(queue: .main),
                   userInfoParser: userInfoParser)
    }

    override var currentPhase: ZMAuthenticationPhase {
        return mockPhase
    }

}

@objcMembers
class ZMMockClientRegistrationStatus: ZMClientRegistrationStatus {
    var mockPhase: ClientRegistrationPhase?
    var mockReadiness: Bool = true

    convenience init(managedObjectContext: NSManagedObjectContext) {
        self.init(context: managedObjectContext, cookieProvider: nil, coreCryptoProvider: nil)
    }

    override init(
        context moc: NSManagedObjectContext!,
        cookieProvider: CookieProvider!,
        coreCryptoProvider: CoreCryptoProviderProtocol!
    ) {
        super.init(context: moc, cookieProvider: cookieProvider, coreCryptoProvider: coreCryptoProvider)
        self.emailCredentials = UserEmailCredentials(email: "bla@example.com", password: "secret")
    }

    override var currentPhase: ClientRegistrationPhase {
        if let phase = mockPhase {
            return phase
        }
        return super.currentPhase
    }

    var isLoggedIn: Bool {
        return true
    }

    override var clientIsReadyForRequests: Bool {
        return mockReadiness
    }

    var isWaitingForLoginValue: Bool = false
    override var isWaitingForLogin: Bool {
        return isWaitingForLoginValue
    }

    var isAddingEmailNecessaryValue: Bool = false
    override var isAddingEmailNecessary: Bool {
        return isAddingEmailNecessaryValue
    }
}

class ZMMockClientUpdateStatus: ClientUpdateStatus {
    var fetchedClients: [UserClient?] = []
    var mockPhase: ClientUpdatePhase?
    var deleteCallCount: Int = 0
    var fetchCallCount: Int = 0
    var mockCredentials: UserEmailCredentials = UserEmailCredentials(email: "bla@example.com", password: "secret")

    override var credentials: UserEmailCredentials? {
        return mockCredentials
    }

    override func didFetchClients(_ clients: [UserClient]) {
        fetchedClients = clients
        fetchCallCount += 1
    }

    override func didDeleteClient() {
        deleteCallCount += 1
    }

    override var currentPhase: ClientUpdatePhase {
        if let mockPhase {
            return mockPhase
        }
        return super.currentPhase
    }
}

class FakeCredentialProvider: NSObject, ZMCredentialProvider {
    var clearCallCount = 0
    var email = "hello@example.com"
    var password = "verySafePassword"

    func emailCredentials() -> UserEmailCredentials {
        return UserEmailCredentials(email: email, password: password)
    }

    func credentialsMayBeCleared() {
        clearCallCount += 1
    }
}

class FakeCookieStorage: ZMPersistentCookieStorage {
}

public class MockSyncStatus: SyncStatus {

    var didCallFailCurrentSyncPhase = false
    var didCallFinishCurrentSyncPhase = false

    public var mockPhase: SyncPhase = .done {
        didSet {
            currentSyncPhase = mockPhase
        }
    }

    public override func failCurrentSyncPhase(phase: SyncPhase) {
        didCallFailCurrentSyncPhase = true

        super.failCurrentSyncPhase(phase: phase)
    }

    public override func finishCurrentSyncPhase(phase: SyncPhase) {
        didCallFinishCurrentSyncPhase = true

        super.finishCurrentSyncPhase(phase: phase)
    }
}

@objc public class MockSyncStateDelegate: NSObject, ZMSyncStateDelegate {

    var registeredUserClient: UserClient?
    var registeredMLSClient: UserClient?
    @objc public var didCallStartSlowSync = false
    @objc public var didCallFinishSlowSync = false
    @objc public var didCallStartQuickSync = false
    @objc public var didCallFinishQuickSync = false
    @objc public var didCallFailRegisterUserClient = false
    @objc public var didCallDeleteUserClient = false

    public func didStartSlowSync() {
        didCallStartSlowSync = true
    }

    public func didFinishSlowSync() {
        didCallFinishSlowSync = true
    }

    public func didStartQuickSync() {
        didCallStartQuickSync = true
    }

    public func didFinishQuickSync() {
        didCallFinishQuickSync = true
    }

    public func didRegisterMLSClient(_ userClient: UserClient) {
        registeredMLSClient = userClient
    }

    public func didRegisterSelfUserClient(_ userClient: UserClient) {
        registeredUserClient = userClient
    }

    public func didFailToRegisterSelfUserClient(error: Error) {
        didCallFailRegisterUserClient = true
    }

    public func didDeleteSelfUserClient(error: Error) {
        didCallDeleteUserClient = true
    }
}

@objc public class MockPushMessageHandler: NSObject, PushMessageHandler {

    public func didFailToSend(_ message: ZMMessage) {
        failedToSend.append(message)
    }

    fileprivate(set) var failedToSend: [ZMMessage] = []
}

@objcMembers
public class MockEventConsumer: NSObject, ZMEventConsumer {

    public var eventsProcessed: [ZMUpdateEvent] = []
    public var processEventsCalled: Bool = false
    public func processEvents(_ events: [ZMUpdateEvent], liveEvents: Bool, prefetchResult: ZMFetchRequestBatchResult?) {
        processEventsCalled = true
        eventsProcessed.append(contentsOf: events)
    }

    public var eventsProcessedWhileInBackground: [ZMUpdateEvent] = []
    public var processEventsWhileInBackgroundCalled: Bool = false
    public func processEventsWhileInBackground(_ events: [ZMUpdateEvent]) {
        processEventsWhileInBackgroundCalled = true
        eventsProcessedWhileInBackground.append(contentsOf: events)
    }

    public var messageNoncesToPrefetchCalled: Bool = false
    public func messageNoncesToPrefetch(toProcessEvents events: [ZMUpdateEvent]) -> Set<UUID> {
        messageNoncesToPrefetchCalled = true

        return Set(events.compactMap(\.messageNonce))
    }

    public var conversationRemoteIdentifiersToPrefetchCalled: Bool = false
    public func conversationRemoteIdentifiersToPrefetch(toProcessEvents events: [ZMUpdateEvent]) -> Set<UUID> {
        conversationRemoteIdentifiersToPrefetchCalled = true

        return Set(events.compactMap(\.conversationUUID))
    }

}

@objcMembers public class MockContextChangeTracker: NSObject, ZMContextChangeTracker {

    public var objectsDidChangeCalled: Bool = false
    public func objectsDidChange(_ object: Set<NSManagedObject>) {
        objectsDidChangeCalled = true
    }

    public var fetchRequest: NSFetchRequest<NSFetchRequestResult>?
    public var fetchRequestForTrackedObjectsCalled: Bool = false
    public func fetchRequestForTrackedObjects() -> NSFetchRequest<NSFetchRequestResult>? {
        fetchRequestForTrackedObjectsCalled = true
        return fetchRequest
    }

    public var addTrackedObjectsCalled = false
    public func addTrackedObjects(_ objects: Set<NSManagedObject>) {
        addTrackedObjectsCalled = true
    }

}

@objcMembers
public class MockEventAsyncConsumer: NSObject, ZMEventAsyncConsumer {

    public var eventsProcessed: [ZMUpdateEvent] = []
    public var processEventsCalled: Bool = false
    public func processEvents(_ events: [WireTransport.ZMUpdateEvent]) async {
        processEventsCalled = true
        eventsProcessed.append(contentsOf: events)
    }
}

@objcMembers
public class MockRequestStrategy: NSObject, RequestStrategy {

    public var mockRequestQueue: [ZMTransportRequest] = []
    public var mockRequest: ZMTransportRequest? {
        get {
            mockRequestQueue.last
        }
        set {
            if let request = newValue {
                mockRequestQueue = [request]
            } else {
                mockRequestQueue = []
            }
        }
    }
    public var nextRequestCalled = false
    public func nextRequest(for apiVersion: APIVersion) -> ZMTransportRequest? {
        nextRequestCalled = true
        return mockRequestQueue.popLast()
    }

}
