/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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

class CodableHeaderTests: XCTestCase {
    
    let mock = CodableHeaderMock()
    
    func testHeaderTransformation() {
        let header = mock.getHeader()
        let cbHeader = mock.getCBHeader()
        let transformedHeader = cbHeader.transform()
        XCTAssertTrue(header.isEqual(to: transformedHeader))
    }
    
    func testCBHeaderTransformation() {
        let cbHeader = mock.getCBHeader()
        let transformedHeader = cbHeader.transform()
        let transformedCBHeader = CodableHeader(transformedHeader)
        XCTAssertTrue(compareCBHeaders(lhs: cbHeader, rhs: transformedCBHeader))
    }
}

extension CodableHeaderTests {
    func compareCBHeaders(lhs: CodableHeader, rhs: CodableHeader) -> Bool {
        return
            lhs.applicationBuildName == rhs.applicationBuildName &&
            lhs.applicationBuildNumber == rhs.applicationBuildNumber &&
            lhs.applicationName == rhs.applicationName &&
            lhs.applicationVersion == rhs.applicationVersion &&
            lhs.catrobatLanguageVersion == rhs.catrobatLanguageVersion &&
            lhs.dateTimeUpload == rhs.dateTimeUpload &&
            lhs.description == rhs.description &&
            lhs.deviceName == rhs.deviceName &&
            lhs.isCastProject == rhs.isCastProject &&
            lhs.landscapeMode == rhs.landscapeMode &&
            lhs.mediaLicense == rhs.mediaLicense &&
            lhs.platform == rhs.platform &&
            lhs.platformVersion == rhs.platformVersion &&
            lhs.programLicense == rhs.programLicense &&
            lhs.programName == rhs.programName &&
            lhs.remixOf == rhs.remixOf &&
            lhs.scenesEnabled == rhs.scenesEnabled &&
            lhs.screenHeight == rhs.screenHeight &&
            lhs.screenMode == rhs.screenMode &&
            lhs.screenWidth == rhs.screenWidth &&
            lhs.tags == rhs.tags &&
            lhs.url == rhs.url &&
            lhs.userHandle == rhs.userHandle &&
            lhs.programID == rhs.programID
    }
}
