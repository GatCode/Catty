/**
 *  Copyright (C) 2010-2019 The Catrobat Team
 *  (http://developer.catrobat.org/credits)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  (http://developer.catrobat.org/license_additional_term)
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */

import XCTest

@testable import Pocket_Code

final class CustomExtensionTests: XMLAbstractTest {

    func testIsEmptyButNotNil() {
        let stringEmpty: String? = ""
        let stringNotEmpty: String? = "hello world"
        let stringNil: String? = nil

        XCTAssertTrue(stringEmpty.isEmptyButNotNil())
        XCTAssertFalse(stringNotEmpty.isEmptyButNotNil())
        XCTAssertFalse(stringNil.isEmptyButNotNil())
    }

    func testStringToBool() {
        let stringOK1 = "true"
        let stringOK2 = "1"
        let stringOK3 = "TRUE"
        let stringOK4 = "TrUe"
        let stringWrong1 = "tRu3"

        XCTAssertTrue(stringOK1.bool)
        XCTAssertTrue(stringOK2.bool)
        XCTAssertTrue(stringOK3.bool)
        XCTAssertTrue(stringOK4.bool)
        XCTAssertFalse(stringWrong1.bool)
    }
}