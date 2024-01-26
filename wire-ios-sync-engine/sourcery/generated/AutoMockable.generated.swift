// Generated using Sourcery 2.1.7 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

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

// swiftlint:disable superfluous_disable_command
// swiftlint:disable vertical_whitespace
// swiftlint:disable line_length
// swiftlint:disable variable_name

import Foundation
#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif


@testable import WireSyncEngine





















public class MockGetUserClientFingerprintUseCaseProtocol: GetUserClientFingerprintUseCaseProtocol {

    // MARK: - Life cycle

    public init() {}


    // MARK: - invoke

    public var invokeUserClient_Invocations: [UserClient] = []
    public var invokeUserClient_MockMethod: ((UserClient) async -> Data?)?
    public var invokeUserClient_MockValue: Data??

    public func invoke(userClient: UserClient) async -> Data? {
        invokeUserClient_Invocations.append(userClient)

        if let mock = invokeUserClient_MockMethod {
            return await mock(userClient)
        } else if let mock = invokeUserClient_MockValue {
            return mock
        } else {
            fatalError("no mock for `invokeUserClient`")
        }
    }

}

class MockRecurringActionServiceInterface: RecurringActionServiceInterface {

    // MARK: - Life cycle



    // MARK: - performActionsIfNeeded

    var performActionsIfNeeded_Invocations: [Void] = []
    var performActionsIfNeeded_MockMethod: (() -> Void)?

    func performActionsIfNeeded() {
        performActionsIfNeeded_Invocations.append(())

        guard let mock = performActionsIfNeeded_MockMethod else {
            fatalError("no mock for `performActionsIfNeeded`")
        }

        mock()
    }

    // MARK: - registerAction

    var registerAction_Invocations: [RecurringAction] = []
    var registerAction_MockMethod: ((RecurringAction) -> Void)?

    func registerAction(_ action: RecurringAction) {
        registerAction_Invocations.append(action)

        guard let mock = registerAction_MockMethod else {
            fatalError("no mock for `registerAction`")
        }

        mock(action)
    }

    // MARK: - forcePerformAction

    var forcePerformActionId_Invocations: [String] = []
    var forcePerformActionId_MockMethod: ((String) -> Void)?

    func forcePerformAction(id: String) {
        forcePerformActionId_Invocations.append(id)

        guard let mock = forcePerformActionId_MockMethod else {
            fatalError("no mock for `forcePerformActionId`")
        }

        mock(id)
    }

}

public class MockUserProfile: UserProfile {

    // MARK: - Life cycle

    public init() {}

    // MARK: - lastSuggestedHandle

    public var lastSuggestedHandle: String?


    // MARK: - requestPhoneVerificationCode

    public var requestPhoneVerificationCodePhoneNumber_Invocations: [String] = []
    public var requestPhoneVerificationCodePhoneNumber_MockMethod: ((String) -> Void)?

    public func requestPhoneVerificationCode(phoneNumber: String) {
        requestPhoneVerificationCodePhoneNumber_Invocations.append(phoneNumber)

        guard let mock = requestPhoneVerificationCodePhoneNumber_MockMethod else {
            fatalError("no mock for `requestPhoneVerificationCodePhoneNumber`")
        }

        mock(phoneNumber)
    }

    // MARK: - requestPhoneNumberChange

    public var requestPhoneNumberChangeCredentials_Invocations: [ZMPhoneCredentials] = []
    public var requestPhoneNumberChangeCredentials_MockMethod: ((ZMPhoneCredentials) -> Void)?

    public func requestPhoneNumberChange(credentials: ZMPhoneCredentials) {
        requestPhoneNumberChangeCredentials_Invocations.append(credentials)

        guard let mock = requestPhoneNumberChangeCredentials_MockMethod else {
            fatalError("no mock for `requestPhoneNumberChangeCredentials`")
        }

        mock(credentials)
    }

    // MARK: - requestPhoneNumberRemoval

    public var requestPhoneNumberRemoval_Invocations: [Void] = []
    public var requestPhoneNumberRemoval_MockMethod: (() -> Void)?

    public func requestPhoneNumberRemoval() {
        requestPhoneNumberRemoval_Invocations.append(())

        guard let mock = requestPhoneNumberRemoval_MockMethod else {
            fatalError("no mock for `requestPhoneNumberRemoval`")
        }

        mock()
    }

    // MARK: - requestEmailChange

    public var requestEmailChangeEmail_Invocations: [String] = []
    public var requestEmailChangeEmail_MockError: Error?
    public var requestEmailChangeEmail_MockMethod: ((String) throws -> Void)?

    public func requestEmailChange(email: String) throws {
        requestEmailChangeEmail_Invocations.append(email)

        if let error = requestEmailChangeEmail_MockError {
            throw error
        }

        guard let mock = requestEmailChangeEmail_MockMethod else {
            fatalError("no mock for `requestEmailChangeEmail`")
        }

        try mock(email)
    }

    // MARK: - requestSettingEmailAndPassword

    public var requestSettingEmailAndPasswordCredentials_Invocations: [ZMEmailCredentials] = []
    public var requestSettingEmailAndPasswordCredentials_MockError: Error?
    public var requestSettingEmailAndPasswordCredentials_MockMethod: ((ZMEmailCredentials) throws -> Void)?

    public func requestSettingEmailAndPassword(credentials: ZMEmailCredentials) throws {
        requestSettingEmailAndPasswordCredentials_Invocations.append(credentials)

        if let error = requestSettingEmailAndPasswordCredentials_MockError {
            throw error
        }

        guard let mock = requestSettingEmailAndPasswordCredentials_MockMethod else {
            fatalError("no mock for `requestSettingEmailAndPasswordCredentials`")
        }

        try mock(credentials)
    }

    // MARK: - cancelSettingEmailAndPassword

    public var cancelSettingEmailAndPassword_Invocations: [Void] = []
    public var cancelSettingEmailAndPassword_MockMethod: (() -> Void)?

    public func cancelSettingEmailAndPassword() {
        cancelSettingEmailAndPassword_Invocations.append(())

        guard let mock = cancelSettingEmailAndPassword_MockMethod else {
            fatalError("no mock for `cancelSettingEmailAndPassword`")
        }

        mock()
    }

    // MARK: - requestCheckHandleAvailability

    public var requestCheckHandleAvailabilityHandle_Invocations: [String] = []
    public var requestCheckHandleAvailabilityHandle_MockMethod: ((String) -> Void)?

    public func requestCheckHandleAvailability(handle: String) {
        requestCheckHandleAvailabilityHandle_Invocations.append(handle)

        guard let mock = requestCheckHandleAvailabilityHandle_MockMethod else {
            fatalError("no mock for `requestCheckHandleAvailabilityHandle`")
        }

        mock(handle)
    }

    // MARK: - requestSettingHandle

    public var requestSettingHandleHandle_Invocations: [String] = []
    public var requestSettingHandleHandle_MockMethod: ((String) -> Void)?

    public func requestSettingHandle(handle: String) {
        requestSettingHandleHandle_Invocations.append(handle)

        guard let mock = requestSettingHandleHandle_MockMethod else {
            fatalError("no mock for `requestSettingHandleHandle`")
        }

        mock(handle)
    }

    // MARK: - cancelSettingHandle

    public var cancelSettingHandle_Invocations: [Void] = []
    public var cancelSettingHandle_MockMethod: (() -> Void)?

    public func cancelSettingHandle() {
        cancelSettingHandle_Invocations.append(())

        guard let mock = cancelSettingHandle_MockMethod else {
            fatalError("no mock for `cancelSettingHandle`")
        }

        mock()
    }

    // MARK: - suggestHandles

    public var suggestHandles_Invocations: [Void] = []
    public var suggestHandles_MockMethod: (() -> Void)?

    public func suggestHandles() {
        suggestHandles_Invocations.append(())

        guard let mock = suggestHandles_MockMethod else {
            fatalError("no mock for `suggestHandles`")
        }

        mock()
    }

    // MARK: - add

    public var addObserver_Invocations: [UserProfileUpdateObserver] = []
    public var addObserver_MockMethod: ((UserProfileUpdateObserver) -> Any)?
    public var addObserver_MockValue: Any?

    @objc(addObserver:)
    public func add(observer: UserProfileUpdateObserver) -> Any {
        addObserver_Invocations.append(observer)

        if let mock = addObserver_MockMethod {
            return mock(observer)
        } else if let mock = addObserver_MockValue {
            return mock
        } else {
            fatalError("no mock for `addObserver`")
        }
    }

}

// swiftlint:enable variable_name
// swiftlint:enable line_length
// swiftlint:enable vertical_whitespace
// swiftlint:enable superfluous_disable_command
