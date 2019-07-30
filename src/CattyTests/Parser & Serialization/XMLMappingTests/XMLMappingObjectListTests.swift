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

final class XMLMappingObjectListTests: XMLMappingAbstractTests {

    func testObjectsAreEqual() {
        var cbProject = createBasicCBProject()
        let project = CBXMLMappingToObjc.mapCBProjectToProject(project: cbProject)

        let cbObjectList = cbProject.scenes?[0].objectList?.objects
        let mappedObjectList = project?.objectList

        XCTAssertEqual(cbObjectList?.count, mappedObjectList?.count)
        XCTAssertEqual(cbObjectList?[0].name, (mappedObjectList?[0] as? SpriteObject)?.name)
        XCTAssertEqual(cbObjectList?[1].name, (mappedObjectList?[1] as? SpriteObject)?.name)
    }

    func testLooksAreEqual() {
        var cbProject = createBasicCBProject()
        let project = CBXMLMappingToObjc.mapCBProjectToProject(project: cbProject)

        let cbObjectsCount = cbProject.scenes?[0].objectList?.objects?.count
        let mappedObjectsCount = project?.objectList.count
        XCTAssertEqual(cbObjectsCount, mappedObjectsCount)

        for oIdx in 0..<cbObjectsCount! {
            let cbObject = cbProject.scenes?[0].objectList?.objects?[oIdx]
            let mappedObject = project?.objectList[oIdx] as? SpriteObject

            let cbLookCount = cbObject?.lookList?.looks?.count
            let mappedLookCount = mappedObject?.lookList.count
            XCTAssertEqual(cbLookCount, mappedLookCount)

            for lIdx in 0..<cbLookCount! {
                let cbLook = cbObject?.lookList?.looks?[lIdx]
                let mappedLook = mappedObject?.lookList[lIdx] as? Look

                XCTAssertEqual(cbLook?.name, mappedLook?.name)
                XCTAssertEqual(cbLook?.fileName, mappedLook?.fileName)
            }
        }
    }

    func testSoundsAreEqual() {
        var cbProject = createBasicCBProject()
        let project = CBXMLMappingToObjc.mapCBProjectToProject(project: cbProject)

        let cbObjectsCount = cbProject.scenes?[0].objectList?.objects?.count
        let mappedObjectsCount = project?.objectList.count
        XCTAssertEqual(cbObjectsCount, mappedObjectsCount)

        for oIdx in 0..<cbObjectsCount! {
            let cbObject = cbProject.scenes?[0].objectList?.objects?[oIdx]
            let mappedObject = project?.objectList[oIdx] as? SpriteObject

            let cbSoundCount = cbObject?.soundList?.sounds?.count
            let mappedSoundCount = mappedObject?.soundList.count
            XCTAssertEqual(cbSoundCount, mappedSoundCount)

            for sIdx in 0..<cbSoundCount! {
                let cbSound = cbObject?.soundList?.sounds?[sIdx]
                let mappedSound = mappedObject?.soundList[sIdx] as? Sound

                XCTAssertEqual(cbSound?.name, mappedSound?.name)
                XCTAssertEqual(cbSound?.fileName, mappedSound?.fileName)
            }
        }
    }

    func testScriptsAreEqual() {
        var cbProject = createBasicCBProject()
        let project = CBXMLMappingToObjc.mapCBProjectToProject(project: cbProject)

        let cbObjectsCount = cbProject.scenes?[0].objectList?.objects?.count
        let mappedObjectsCount = project?.objectList.count
        XCTAssertEqual(cbObjectsCount, mappedObjectsCount)

        for oIdx in 0..<cbObjectsCount! {
            let cbObject = cbProject.scenes?[0].objectList?.objects?[oIdx]
            let mappedObject = project?.objectList[oIdx] as? SpriteObject

            let cbScriptCount = cbObject?.scriptList?.scripts?.count
            let mappedScriptCount = mappedObject?.scriptList.count
            XCTAssertEqual(cbScriptCount, mappedScriptCount)

            for sIdx in 0..<cbScriptCount! {
                let cbScript = cbObject?.scriptList?.scripts?[sIdx]
                let mappedScript = mappedObject?.scriptList[sIdx] as? Script

                XCTAssertNotNil(cbScript?.type)
                XCTAssertNotNil(mappedScript?.brickTitle)
            }
        }
    }

    func testBricksAreEqual() {
        var cbProject = createBasicCBProject()
        let project = CBXMLMappingToObjc.mapCBProjectToProject(project: cbProject)

        let cbObjectsCount = cbProject.scenes?[0].objectList?.objects?.count
        let mappedObjectsCount = project?.objectList.count
        XCTAssertEqual(cbObjectsCount, mappedObjectsCount)

        for oIdx in 0..<cbObjectsCount! {
            let cbObject = cbProject.scenes?[0].objectList?.objects?[oIdx]
            let mappedObject = project?.objectList[oIdx] as? SpriteObject

            let cbScriptCount = cbObject?.scriptList?.scripts?.count
            let mappedScriptCount = mappedObject?.scriptList.count
            XCTAssertEqual(cbScriptCount, mappedScriptCount)

            for sIdx in 0..<cbScriptCount! {
                let cbScript = cbObject?.scriptList?.scripts?[sIdx]
                let mappedScript = mappedObject?.scriptList[sIdx] as? Script

                let cbBrickCount = cbScript?.brickList?.bricks?.count
                let mappedBrickCount = mappedScript?.brickList.count
                XCTAssertEqual(cbBrickCount, mappedBrickCount)

                for bIdx in 0..<cbBrickCount! {
                    let cbBrick = cbScript?.brickList?.bricks?[bIdx]
                    let mappedBrick = mappedScript?.brickList[bIdx] as? Brick

                    XCTAssertNotNil(cbBrick?.type)
                    XCTAssertNotNil(mappedBrick?.brickTitle)
                }
            }
        }
    }

    func testBothSoundsHaveSameAddress() {
        var cbProject: CBProject?
        getProjectForXML(xmlFile: "SoundMapping") { project, error  in
            XCTAssertNil(error)
            cbProject = project
        }

        let project = CBXMLMappingToObjc.mapCBProjectToProject(project: cbProject)

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
        getProjectForXML(xmlFile: "LookMapping") { project, error  in
            XCTAssertNil(error)
            cbProject = project
        }

        let project = CBXMLMappingToObjc.mapCBProjectToProject(project: cbProject)

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
        getProjectForXML(xmlFile: "VariableMapping") { project, error  in
            XCTAssertNil(error)
            cbProject = project
        }

        let project = CBXMLMappingToObjc.mapCBProjectToProject(project: cbProject)

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
        getProjectForXML(xmlFile: "VariableMapping2") { project, error  in
            XCTAssertNil(error)
            cbProject = project
        }

        XCTAssertNotNil(cbProject)

        let project = CBXMLMappingToObjc.mapCBProjectToProject(project: cbProject)

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

    func testUninitializedVariableListMapping() {
        var cbProject: CBProject?
        getProjectForXML(xmlFile: "VariableMapping3") { project, error  in
            XCTAssertNil(error)
            cbProject = project
        }

        XCTAssertNotNil(cbProject)

        let project = CBXMLMappingToObjc.mapCBProjectToProject(project: cbProject)
        let spriteObject = project?.objectList[0] as? SpriteObject
        let formulaElement = (((spriteObject?.scriptList[0] as? Script)?.brickList[0] as? IfThenLogicBeginBrick)?.getFormulas()?.first)?.formulaTree

        XCTAssertNotNil(project?.variables.getUserListNamed(formulaElement?.value, for: spriteObject))
    }

    func testBroadcastsHaveSameValues() {
        var cbProject: CBProject?
        getProjectForXML(xmlFile: "BroadcastMapping") { project, error  in
            XCTAssertNil(error)
            cbProject = project
        }

        let project = CBXMLMappingToObjc.mapCBProjectToProject(project: cbProject)

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
