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

final class XMLMappingHeaderTests: XMLMappingAbstractTests {

    func testHeadersAreEqual() {
        var cbProject = CBProject()
        var header = CBHeader()
        header.applicationBuildName = "applicationBuildName"
        header.applicationName = "applicationName"
        header.catrobatLanguageVersion = "catrobatLanguageVersion"
        header.description = "description"
        header.remixOf = "remixOf"
        header.url = "url"
        header.userHandle = "userHandle"
        header.programID = "programID"
        cbProject.header = header

        let project = CBXMLMappingToObjc.mapCBProjectToProject(project: cbProject)

        XCTAssertEqual(cbProject.header?.applicationBuildName, project?.header.applicationBuildName)
        XCTAssertEqual(cbProject.header?.applicationName, project?.header.applicationName)
        XCTAssertEqual(cbProject.header?.catrobatLanguageVersion, project?.header.catrobatLanguageVersion)
        XCTAssertEqual(cbProject.header?.description, project?.header.programDescription)
        XCTAssertEqual(cbProject.header?.remixOf, project?.header.remixOf)
        XCTAssertEqual(cbProject.header?.url, project?.header.url)
        XCTAssertEqual(cbProject.header?.userHandle, project?.header.userHandle)
        XCTAssertEqual(cbProject.header?.programID, project?.header.programID)
    }
}
