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

    func testVariablesHaveSameAddresses2() {
        var cbProject: CBProject?
        getProjectForXML2(xmlFile: "VariableMapping2") { project, error  in
            XCTAssertNil(error)
            cbProject = project
        }

        XCTAssertNotNil(cbProject)

        let project = CBXMLMapping.mapCBProjectToProject(project: cbProject)

        if let object1 = project?.objectList[0] as? SpriteObject, let object2 = project?.objectList[1] as? SpriteObject {
            if let scriptList1 = object1.scriptList, let scriptList2 = object2.scriptList {
                let o1Local1 = ((scriptList1[0] as? Script)?.brickList[0] as? SetVariableBrick)?.userVariable
                let o1Local2 = ((scriptList1[0] as? Script)?.brickList[1] as? ChangeVariableBrick)?.userVariable
                XCTAssert(o1Local1 === o1Local2)

                let o2Local1 = ((scriptList2[0] as? Script)?.brickList[0] as? SetVariableBrick)?.userVariable
                let o2Local2 = ((scriptList2[0] as? Script)?.brickList[1] as? ChangeVariableBrick)?.userVariable
                XCTAssert(o2Local1 === o2Local2)

                XCTAssertNotNil(o1Local1)
                XCTAssertNotNil(o2Local1)
                XCTAssertFalse(o1Local1 === o2Local1)
            }
        }
    }

    func testBroadcastsHaveSameValues() {
        var cbProject: CBProject?
        getProjectForXML2(xmlFile: "BroadcastMapping") { project, error  in
            XCTAssertNil(error)
            cbProject = project
        }

        let project = CBXMLMapping.mapCBProjectToProject(project: cbProject)

        if let object = project?.objectList.firstObject as? SpriteObject {
            if let scriptList = object.scriptList {
                XCTAssertEqual(scriptList.count, 2)

                let broadcast1 = ((scriptList[0] as? Script)?.brickList[0] as? BroadcastBrick)?.broadcastMessage
                let broadcast2 = ((scriptList[1] as? Script)?.brickList[0] as? BroadcastBrick)?.broadcastMessage
                XCTAssert(broadcast1 == broadcast2)

                let broadcastWait1 = ((scriptList[0] as? Script)?.brickList[1] as? BroadcastWaitBrick)?.broadcastMessage
                let broadcastWait2 = ((scriptList[1] as? Script)?.brickList[1] as? BroadcastWaitBrick)?.broadcastMessage
                XCTAssert(broadcastWait1 == broadcastWait2)
            }
        }
    }
}
