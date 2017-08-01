//
// Wire
// Copyright (C) 2017 Wire Swiss GmbH
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

import XCTest
@testable import WireSyncEngine

final class TestUnauthenticatedTransportSession: UnauthenticatedTransportSessionProtocol, ReachabilityProvider {

    public var mockMaybeReachable = true
    public var cookieStorage = ZMPersistentCookieStorage()
    var nextEnqueueResult: EnqueueResult = .nilRequest
    var didReceiveUserInfo: UserInfoAvailableClosure?

    func enqueueRequest(withGenerator generator: () -> ZMTransportRequest?) -> EnqueueResult {
        return nextEnqueueResult
    }

    var mayBeReachable: Bool {
        return mockMaybeReachable
    }

}


final class TestAuthenticationObserver: NSObject, ZMAuthenticationObserver {
    public var authenticationDidSucceedEvents: Int = 0
    public var authenticationDidFailEvents: [Error] = []
    
    private var observationToken: ZMAuthenticationObserverToken! = nil
    
    override init() {
        super.init()
        observationToken = ZMUserSessionAuthenticationNotification.addObserver(self)
    }
    
    deinit {
        ZMUserSessionAuthenticationNotification.removeObserver(for: observationToken)
    }
    
    func authenticationDidSucceed() {
        authenticationDidSucceedEvents = authenticationDidSucceedEvents + 1
    }
    
    func authenticationDidFail(_ error: Error) {
        authenticationDidFailEvents.append(error)
    }
}

public final class UnauthenticatedSessionTests: XCTestCase {
    var transportSession: TestUnauthenticatedTransportSession!
    var sut: UnauthenticatedSession!
    
    public override func setUp() {
        super.setUp()
        transportSession = TestUnauthenticatedTransportSession()
        sut = UnauthenticatedSession(transportSession: transportSession, delegate: nil)
    }
    
    public override func tearDown() {
        sut.tearDown()
        sut = nil
        transportSession = nil
        super.tearDown()
    }
    
    func testThatDuringLoginItThrowsErrorWhenNoCredentials() {
        let observer = TestAuthenticationObserver()
        // given
        transportSession.mockMaybeReachable = false
        // when
        sut.login(with: ZMCredentials())
        // then
        XCTAssertEqual(observer.authenticationDidSucceedEvents, 0)
        XCTAssertEqual(observer.authenticationDidFailEvents.count, 1)
        XCTAssertEqual(observer.authenticationDidFailEvents[0].localizedDescription, NSError.userSessionErrorWith(.needsCredentials, userInfo:nil).localizedDescription)
    }
    
    func testThatDuringLoginItThrowsErrorWhenOffline() {
        let observer = TestAuthenticationObserver()
        // given
        transportSession.mockMaybeReachable = false
        // when
        sut.login(with: ZMEmailCredentials(email: "my@mail.com", password: "my-password"))
        // then
        XCTAssertEqual(observer.authenticationDidSucceedEvents, 0)
        XCTAssertEqual(observer.authenticationDidFailEvents.count, 1)
        XCTAssertEqual(observer.authenticationDidFailEvents[0].localizedDescription, NSError.userSessionErrorWith(.networkError, userInfo:nil).localizedDescription)
    }
}
