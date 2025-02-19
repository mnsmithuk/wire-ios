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

@testable import Wire

final class MockMainCoordinator: MainCoordinating {

    func openConversation(
        _ conversation: ZMConversation,
        focusOnView focus: Bool,
        animated: Bool
    ) {
        fatalError("Mock method not implemented")
    }

    func openConversation<Message>(
        _ conversation: ZMConversation,
        scrollTo message: Message,
        focusOnView focus: Bool,
        animated: Bool
    ) where Message: ZMConversationMessage {
        fatalError("Mock method not implemented")
    }

    func showConversationList() {
        fatalError("Mock method not implemented")
    }

    func showSettings() {
        fatalError("Mock method not implemented")
    }
}

// MARK: - MainCoordinating + mock

extension MainCoordinating where Self == MockMainCoordinator {

    static var mock: Self { .init() }
}
