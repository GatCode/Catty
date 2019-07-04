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

final class XMLMappingTests: XMLAbstractTest {

    func testBothSoundsHaveSameAddress() {
        var cbProject: CBProject?
        getProjectForXML2(xmlFile: "SoundMapping") { project, error  in
            XCTAssertNil(error)
            cbProject = project
        }

        let project = CBXMLMapping.mapCBProjectToProject(project: cbProject)

        if let object = project?.objectList.firstObject as? SpriteObject {
            if let scriptList = object.scriptList {
                XCTAssertEqual(scriptList.count, 2)
                let soundFromScript1 = ((scriptList[0] as? Script)?.brickList.firstObject as? PlaySoundBrick)?.sound
                let soundFromScript2 = ((scriptList[1] as? Script)?.brickList.firstObject as? PlaySoundBrick)?.sound
                XCTAssert(soundFromScript1 === soundFromScript2)
            }
        }
    }

    func testBothLooksHaveSameAddress() {
        var cbProject: CBProject?
        getProjectForXML2(xmlFile: "LookMapping") { project, error  in
            XCTAssertNil(error)
            cbProject = project
        }

        let project = CBXMLMapping.mapCBProjectToProject(project: cbProject)

        if let object = project?.objectList.firstObject as? SpriteObject {
            if let scriptList = object.scriptList {
                XCTAssertEqual(scriptList.count, 2)
                let soundFromScript1 = ((scriptList[0] as? Script)?.brickList.firstObject as? SetLookBrick)?.look
                let soundFromScript2 = ((scriptList[1] as? Script)?.brickList.firstObject as? SetLookBrick)?.look
                XCTAssert(soundFromScript1 === soundFromScript2)
            }
        }
    }

    func testVariablesHaveSameAddresses() {
        var cbProject: CBProject?
        getProjectForXML2(xmlFile: "VariableMapping") { project, error  in
            XCTAssertNil(error)
            cbProject = project
        }

        let project = CBXMLMapping.mapCBProjectToProject(project: cbProject)

        if let object = project?.objectList.firstObject as? SpriteObject {
            if let scriptList = object.scriptList {
                XCTAssertEqual(scriptList.count, 2)

                let localVar1 = ((scriptList[0] as? Script)?.brickList[0] as? SetVariableBrick)?.userVariable
                let localVar2 = ((scriptList[1] as? Script)?.brickList[0] as? SetVariableBrick)?.userVariable
                XCTAssert(localVar1 === localVar2)

                let globalVar1 = ((scriptList[0] as? Script)?.brickList[1] as? SetVariableBrick)?.userVariable
                let globalVar2 = ((scriptList[1] as? Script)?.brickList[1] as? SetVariableBrick)?.userVariable
                XCTAssert(globalVar1 === globalVar2)

                let localList1 = ((scriptList[0] as? Script)?.brickList[2] as? AddItemToUserListBrick)?.userList
                let localList2 = ((scriptList[1] as? Script)?.brickList[2] as? AddItemToUserListBrick)?.userList
                XCTAssert(localList1 === localList2)

                let globalList1 = ((scriptList[0] as? Script)?.brickList[3] as? AddItemToUserListBrick)?.userList
                let globalList2 = ((scriptList[1] as? Script)?.brickList[3] as? AddItemToUserListBrick)?.userList
                XCTAssert(globalList1 === globalList2)
            }
        }
    }
}
