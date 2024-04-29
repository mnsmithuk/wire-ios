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

import WireDataModel
import XCTest

final class ZMSearchUserTests_Connections: ModelObjectsTests {

    func testThatConnectSendsAConnectToUserNotification() {
        // given
        let searchUser = ZMSearchUser(
            contextProvider: coreDataStack,
            name: "John Doe",
            handle: "johndoe",
            accentColor: .turquoise,
            remoteIdentifier: UUID(),
            searchUsersCache: nil
        )

        // expect
        customExpectation(forNotification: ConnectToUserAction.notificationName, object: nil)

        // when
        searchUser.connect { _ in }

        // then
        XCTAssertTrue(waitForCustomExpectations(withTimeout: 0.5))
    }
}
