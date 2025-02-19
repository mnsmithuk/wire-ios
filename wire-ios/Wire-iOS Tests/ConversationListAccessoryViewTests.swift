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

import WireTestingPackage
import XCTest

@testable import Wire

final class ConversationListAccessoryViewTests: XCTestCase {

    // MARK: - Properties

    private var snapshotHelper: SnapshotHelper!
    private var sut: ConversationListAccessoryView!
    private var userSession: UserSessionMock!

    // MARK: - setUp

    override func setUp() {
        super.setUp()
        snapshotHelper = SnapshotHelper()
        userSession = UserSessionMock()
        self.sut = ConversationListAccessoryView(mediaPlaybackManager: MediaPlaybackManager(name: "test", userSession: userSession))
        accentColor = .purple
    }

    // MARK: - tearDown

    override func tearDown() {
        snapshotHelper = nil
        sut = nil
        userSession = nil
        super.tearDown()
    }

    // MARK: - Snapshot Tests

    func testThatItIsEmptyForNoStatus() {
        // WHEN
        sut.icon = nil
        // THEN
        sut.setNeedsLayout()
        sut.layoutIfNeeded()
        XCTAssertEqual(sut.frame.size.width, 0)
    }

    func testThatItShowsUnreadMessages() {
        // WHEN
        sut.icon = ConversationStatusIcon.unreadMessages(count: 3)
        // THEN
        snapshotHelper.verify(matching: sut)
    }

    func testThatItShowsALotOfUnreadMessages() {
        // WHEN
        sut.icon = ConversationStatusIcon.unreadMessages(count: 500)
        // THEN
        snapshotHelper.verify(matching: sut)
    }

    func testThatItShowsJoinButton() {
        // WHEN
        sut.icon = ConversationStatusIcon.activeCall(showJoin: true)
        // THEN
        snapshotHelper.verify(matching: sut)
    }

    func testThatItShowsOngoingCallIndicator() {
        // WHEN
        sut.icon = ConversationStatusIcon.activeCall(showJoin: false)
        // THEN
        snapshotHelper.verify(matching: sut)
    }

    func testThatItShowsMissedCall() {
        // WHEN
        sut.icon = ConversationStatusIcon.missedCall
        // THEN
        snapshotHelper.verify(matching: sut)
    }

    func testThatItShowsMissedPing() {
        // WHEN
        sut.icon = ConversationStatusIcon.unreadPing
        // THEN
        snapshotHelper.verify(matching: sut)
    }

    func testThatItShowsTyping() {
        // WHEN
        sut.icon = ConversationStatusIcon.typing
        // THEN
        snapshotHelper.verify(matching: sut)
    }

    func testThatItShowsSilenced() {
        // WHEN
        sut.icon = ConversationStatusIcon.silenced
        // THEN
        snapshotHelper.verify(matching: sut)
    }

    func testThatItShowsPlayingMedia() {
        // WHEN
        sut.icon = ConversationStatusIcon.playingMedia
        // THEN
        snapshotHelper.verify(matching: sut)
    }

    func testThatItShowsPendingConnection() {
        // WHEN
        sut.icon = ConversationStatusIcon.pendingConnection
        // THEN
        snapshotHelper.verify(matching: sut)
    }

    func testThatItRecoversFromPreviousState() {
        // WHEN
        sut.icon = ConversationStatusIcon.unreadPing
        sut.icon = ConversationStatusIcon.typing

        // THEN
        snapshotHelper.verify(matching: sut)
    }

    func testThatItShowsMention() {
        // WHEN
        sut.icon = ConversationStatusIcon.mention
        // THEN
        snapshotHelper.verify(matching: sut)
    }

    func testThatItShowsReply() {
        // WHEN
        sut.icon = ConversationStatusIcon.reply
        // THEN
        snapshotHelper.verify(matching: sut)
    }
}
