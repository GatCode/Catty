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
import XMLCoder

@testable import Pocket_Code

final class XMLCoderTests: XCTestCase {

    let mock = HeaderMock()
    var encoder: XMLEncoder!
    var decoder: XMLDecoder!

    override func setUp() {
        super.setUp()
        self.encoder = XMLEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.userInfo = [CodingUserInfoKey(rawValue: "CatrobatLanguageVersion")!: 0.991]

        self.decoder = XMLDecoder()
    }

    func testEncode() {
        let cbHeader = mock.getCBHeader()
        let xmlData = try? encoder.encode(cbHeader, withRootKey: "header")
        let xmlString = String(decoding: xmlData!, as: UTF8.self)
        XCTAssertFalse(xmlString.isEmpty)
    }

    func testDecode() {
        let xmlStr = mock.getXML()
        let data = xmlStr.data(using: .utf8)!
        let cbHeader = try? decoder.decode(CBHeader.self, from: data)
        XCTAssertNotNil(cbHeader)
    }

    func testDecodeFailRequiredValuesMissing() {
        let xmlStr = """
        <header>
            <applicationBuildName>Catty</applicationBuildName>
        </header>
        """

        let data = xmlStr.data(using: .utf8)!
        let cbHeader = try? decoder.decode(CBHeader.self, from: data)
        XCTAssertNil(cbHeader)
    }

    func compareHeaders(left: CBHeader, right: CBHeader) {
        XCTAssertEqual(left.applicationBuildName, right.applicationBuildName)
        XCTAssertEqual(left.applicationBuildNumber, right.applicationBuildNumber)
        XCTAssertEqual(left.applicationName, right.applicationName)
        XCTAssertEqual(left.applicationVersion, right.applicationVersion)
        XCTAssertEqual(left.dateTimeUpload, right.dateTimeUpload)
        XCTAssertEqual(left.description, right.description)
        XCTAssertEqual(left.deviceName, right.deviceName)
        XCTAssertEqual(left.landscapeMode, right.landscapeMode)
        XCTAssertEqual(left.mediaLicense, right.mediaLicense)
        XCTAssertEqual(left.platform, right.platform)
        XCTAssertEqual(left.platformVersion, right.platformVersion)
        XCTAssertEqual(left.programLicense, right.programLicense)
        XCTAssertEqual(left.programName, right.programName)
        XCTAssertEqual(left.remixOf, right.remixOf)
        XCTAssertEqual(left.screenHeight, right.screenHeight)
        XCTAssertEqual(left.screenWidth, right.screenWidth)
        XCTAssertEqual(left.screenMode, right.screenMode)
        XCTAssertEqual(left.tags, right.tags)
        XCTAssertEqual(left.url, right.url)
        XCTAssertEqual(left.userHandle, right.userHandle)
        XCTAssertEqual(left.programID, right.programID)
    }

    func compareHeaders(left: Header, right: Header) {
        XCTAssertEqual(left.applicationBuildName, right.applicationBuildName)
        XCTAssertEqual(left.applicationBuildNumber, right.applicationBuildNumber)
        XCTAssertEqual(left.applicationName, right.applicationName)
        XCTAssertEqual(left.applicationVersion, right.applicationVersion)
        XCTAssertEqual(left.catrobatLanguageVersion, right.catrobatLanguageVersion)
        XCTAssertEqual(left.dateTimeUpload, right.dateTimeUpload)
        XCTAssertEqual(left.programDescription, right.programDescription)
        XCTAssertEqual(left.deviceName, right.deviceName)
        XCTAssertEqual(left.landscapeMode, right.landscapeMode)
        XCTAssertEqual(left.mediaLicense, right.mediaLicense)
        XCTAssertEqual(left.platform, right.platform)
        XCTAssertEqual(left.platformVersion, right.platformVersion)
        XCTAssertEqual(left.programLicense, right.programLicense)
        XCTAssertEqual(left.programName, right.programName)
        XCTAssertEqual(left.remixOf, right.remixOf)
        XCTAssertEqual(left.screenHeight, right.screenHeight)
        XCTAssertEqual(left.screenWidth, right.screenWidth)
        XCTAssertEqual(left.screenMode, right.screenMode)
        XCTAssertEqual(left.tags, right.tags)
        XCTAssertEqual(left.url, right.url)
        XCTAssertEqual(left.userHandle, right.userHandle)
        XCTAssertEqual(left.programID, right.programID)
    }
}
