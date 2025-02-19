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

import Foundation
import WireDataModel

public class RemovePushTokenAction: EntityAction {

    // MARK: - Types

    public typealias Result = Void

    public enum Failure: LocalizedError, SafeForLoggingStringConvertible {

        case tokenDoesNotExist
        case unknown(status: Int)

        public var errorDescription: String? {
            switch self {
            case .tokenDoesNotExist:
                return "Push token does not exist."

            case .unknown(let status):
                return "Unknown error (response status: \(status))"
            }
        }

        public var safeForLoggingDescription: String {
            return errorDescription ?? ""
        }
    }

    // MARK: - Properties

    public var resultHandler: ResultHandler?

    public let deviceToken: String

    // MARK: - Life cycle

    public init(deviceToken: String, resultHandler: ResultHandler? = nil) {
        self.deviceToken = deviceToken
        self.resultHandler = resultHandler
    }

}
