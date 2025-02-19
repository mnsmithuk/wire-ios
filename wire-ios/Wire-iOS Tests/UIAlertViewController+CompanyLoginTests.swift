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

@testable import Wire
import XCTest

final class UIAlertControllerCompanyLoginSnapshotTests: XCTestCase {
    var sut: UIAlertController!

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testForSSOAndEmailAlert() throws {
        sut = UIAlertController.companyLogin(ssoOnly: false, completion: { _  in })
        try verify(matching: sut)
    }

    func testForSSOOnlyAlert() throws {
        sut = UIAlertController.companyLogin(ssoOnly: true, completion: { _  in })
        try verify(matching: sut)
    }

    func testForAlertWithError() throws {
        sut = UIAlertController.companyLogin(error: .unknown) { _  in }
        try verify(matching: sut)
    }

}
