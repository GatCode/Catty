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

    func createBasicCBProject() -> CBProject {
        let sceneList = [CBProjectScene(name: "Scene1")]
        let objectList = CBObjectList(object: [CBObject(name: "Object1"), CBObject(name: "Object2")])
        let lookList = CBLookList(look: [CBLook(name: "Look1", fileName: "File1"), CBLook(name: "Look2", fileName: "File1")])
        let soundList = CBSoundList(sound: [CBSound(fileName: "File1", name: "Sound1", reference: "../ref1"), CBSound(fileName: "File2", name: "Sound2", reference: "../ref2")])
        let scriptList = CBScriptList(script: [CBScript(type: "Script"), CBScript(type: "BroadcastScript")])
        let brickList = CBBrickList(brick: [CBBrick(name: "Brick1", type: "SetVariableBrick"), CBBrick(name: "Brick2", type: "SetVariableBrick")])
        let userVariable = "UVar1"
        let userList = "UList1"

        var cbProject = CBProject()
        cbProject.scenes = sceneList
        for sceneIdx in 0..<(cbProject.scenes?.count)! {
            cbProject.scenes?[sceneIdx].objectList = objectList
            for objectIdx in 0..<(cbProject.scenes?[sceneIdx].objectList?.object?.count)! {
                cbProject.scenes?[sceneIdx].objectList?.object?[objectIdx].lookList = lookList
                cbProject.scenes?[sceneIdx].objectList?.object?[objectIdx].soundList = soundList
                cbProject.scenes?[sceneIdx].objectList?.object?[objectIdx].scriptList = scriptList
                for scriptIdx in 0..<(cbProject.scenes?[sceneIdx].objectList?.object?[objectIdx].scriptList?.script?.count)! {
                    cbProject.scenes?[sceneIdx].objectList?.object?[objectIdx].scriptList?.script?[scriptIdx].brickList = brickList
                    for brickIdx in 0..<(cbProject.scenes?[sceneIdx].objectList?.object?[objectIdx].scriptList?.script?[scriptIdx].brickList?.brick?.count)! {
                        cbProject.scenes?[sceneIdx].objectList?.object?[objectIdx].scriptList?.script?[scriptIdx].brickList?.brick?[brickIdx].userVariable = userVariable
                        cbProject.scenes?[sceneIdx].objectList?.object?[objectIdx].scriptList?.script?[scriptIdx].brickList?.brick?[brickIdx].userList = userList
                    }
                }
            }
        }

        return cbProject
    }

    func createExtendedCBProject() -> CBProject {

        let programVariableListEntries = [CBUserProgramVariable(value: "Value1"), CBUserProgramVariable(value: "Value2")]
        let programVariableList = CBProgramVariableList(userVariable: programVariableListEntries)
        let programListOfListsEntries = [CBProgramList(name: "Value1"), CBProgramList(name: "Value2")]
        let programListOfLists = CBProgramListOfLists(list: programListOfListsEntries)

        var cbProject = createBasicCBProject()
        cbProject.programVariableList = programVariableList
        cbProject.programListOfLists = programListOfLists

        return cbProject
    }

    func createExtendedCBProjectWithReferencedUserVariable() -> (CBProject, String) {

        var cbProject = createBasicCBProject()

        let referencedList = "../../../objectList/object/scriptList/script/brickList/brick/userList"
        let referencedVariable = "../../../objectList/object/scriptList/script/brickList/brick/userVariable"
        let referencedVariableName = cbProject.scenes?[0].objectList?.object?[0].scriptList?.script?[0].brickList?.brick?[0].userVariable

        let programVariableList = CBProgramVariableList(userVariable: [CBUserProgramVariable(reference: referencedVariable)])
        let programListOfLists = CBProgramListOfLists(list: [CBProgramList(reference: referencedList)])

        cbProject.programVariableList = programVariableList
        cbProject.programListOfLists = programListOfLists

        return (cbProject, referencedVariableName!)
    }

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

        let project = CBXMLMapping.mapCBProjectToProject(project: cbProject)

        XCTAssertEqual(cbProject.header?.applicationBuildName, project?.header.applicationBuildName)
        XCTAssertEqual(cbProject.header?.applicationName, project?.header.applicationName)
        XCTAssertEqual(cbProject.header?.catrobatLanguageVersion, project?.header.catrobatLanguageVersion)
        XCTAssertEqual(cbProject.header?.description, project?.header.programDescription)
        XCTAssertEqual(cbProject.header?.remixOf, project?.header.remixOf)
        XCTAssertEqual(cbProject.header?.url, project?.header.url)
        XCTAssertEqual(cbProject.header?.userHandle, project?.header.userHandle)
        XCTAssertEqual(cbProject.header?.programID, project?.header.programID)
    }

    func testObjectsAreEqual() {
        var cbProject = createBasicCBProject()
        let project = CBXMLMapping.mapCBProjectToProject(project: cbProject)

        let cbObjectList = cbProject.scenes?[0].objectList?.object
        let mappedObjectList = project?.objectList

        XCTAssertEqual(cbObjectList?.count, mappedObjectList?.count)
        XCTAssertEqual(cbObjectList?[0].name, (mappedObjectList?[0] as? SpriteObject)?.name)
        XCTAssertEqual(cbObjectList?[1].name, (mappedObjectList?[1] as? SpriteObject)?.name)
    }

    func testLooksAreEqual() {
        var cbProject = createBasicCBProject()
        let project = CBXMLMapping.mapCBProjectToProject(project: cbProject)

        let cbObjectsCount = cbProject.scenes?[0].objectList?.object?.count
        let mappedObjectsCount = project?.objectList.count
        XCTAssertEqual(cbObjectsCount, mappedObjectsCount)

        for oIdx in 0..<cbObjectsCount! {
            let cbObject = cbProject.scenes?[0].objectList?.object?[oIdx]
            let mappedObject = project?.objectList[oIdx] as? SpriteObject

            let cbLookCount = cbObject?.lookList?.look?.count
            let mappedLookCount = mappedObject?.lookList.count
            XCTAssertEqual(cbLookCount, mappedLookCount)

            for lIdx in 0..<cbLookCount! {
                let cbLook = cbObject?.lookList?.look?[lIdx]
                let mappedLook = mappedObject?.lookList[lIdx] as? Look

                XCTAssertEqual(cbLook?.name, mappedLook?.name)
                XCTAssertEqual(cbLook?.fileName, mappedLook?.fileName)
            }
        }
    }

    func testSoundsAreEqual() {
        var cbProject = createBasicCBProject()
        let project = CBXMLMapping.mapCBProjectToProject(project: cbProject)

        let cbObjectsCount = cbProject.scenes?[0].objectList?.object?.count
        let mappedObjectsCount = project?.objectList.count
        XCTAssertEqual(cbObjectsCount, mappedObjectsCount)

        for oIdx in 0..<cbObjectsCount! {
            let cbObject = cbProject.scenes?[0].objectList?.object?[oIdx]
            let mappedObject = project?.objectList[oIdx] as? SpriteObject

            let cbSoundCount = cbObject?.soundList?.sound?.count
            let mappedSoundCount = mappedObject?.soundList.count
            XCTAssertEqual(cbSoundCount, mappedSoundCount)

            for sIdx in 0..<cbSoundCount! {
                let cbSound = cbObject?.soundList?.sound?[sIdx]
                let mappedSound = mappedObject?.soundList[sIdx] as? Sound

                XCTAssertEqual(cbSound?.name, mappedSound?.name)
                XCTAssertEqual(cbSound?.fileName, mappedSound?.fileName)
            }
        }
    }

    func testScriptsAreEqual() {
        var cbProject = createBasicCBProject()
        let project = CBXMLMapping.mapCBProjectToProject(project: cbProject)

        let cbObjectsCount = cbProject.scenes?[0].objectList?.object?.count
        let mappedObjectsCount = project?.objectList.count
        XCTAssertEqual(cbObjectsCount, mappedObjectsCount)

        for oIdx in 0..<cbObjectsCount! {
            let cbObject = cbProject.scenes?[0].objectList?.object?[oIdx]
            let mappedObject = project?.objectList[oIdx] as? SpriteObject

            let cbScriptCount = cbObject?.scriptList?.script?.count
            let mappedScriptCount = mappedObject?.scriptList.count
            XCTAssertEqual(cbScriptCount, mappedScriptCount)

            for sIdx in 0..<cbScriptCount! {
                let cbScript = cbObject?.scriptList?.script?[sIdx]
                let mappedScript = mappedObject?.scriptList[sIdx] as? Script

                XCTAssertNotNil(cbScript?.type)
                XCTAssertNotNil(mappedScript?.brickTitle)
            }
        }
    }

    func testBricksAreEqual() {
        var cbProject = createBasicCBProject()
        let project = CBXMLMapping.mapCBProjectToProject(project: cbProject)

        let cbObjectsCount = cbProject.scenes?[0].objectList?.object?.count
        let mappedObjectsCount = project?.objectList.count
        XCTAssertEqual(cbObjectsCount, mappedObjectsCount)

        for oIdx in 0..<cbObjectsCount! {
            let cbObject = cbProject.scenes?[0].objectList?.object?[oIdx]
            let mappedObject = project?.objectList[oIdx] as? SpriteObject

            let cbScriptCount = cbObject?.scriptList?.script?.count
            let mappedScriptCount = mappedObject?.scriptList.count
            XCTAssertEqual(cbScriptCount, mappedScriptCount)

            for sIdx in 0..<cbScriptCount! {
                let cbScript = cbObject?.scriptList?.script?[sIdx]
                let mappedScript = mappedObject?.scriptList[sIdx] as? Script

                let cbBrickCount = cbScript?.brickList?.brick?.count
                let mappedBrickCount = mappedScript?.brickList.count
                XCTAssertEqual(cbBrickCount, mappedBrickCount)

                for bIdx in 0..<cbBrickCount! {
                    let cbBrick = cbScript?.brickList?.brick?[bIdx]
                    let mappedBrick = mappedScript?.brickList[bIdx] as? Brick

                    XCTAssertNotNil(cbBrick?.name)
                    XCTAssertNotNil(mappedBrick?.brickTitle)
                }
            }
        }
    }

    func testProgramVariableListsAreEqual() {
        let cbProject = createExtendedCBProject()
        let project = CBXMLMapping.mapCBProjectToProject(project: cbProject)

        let cbProgramVariableListCount = cbProject.programVariableList?.userVariable?.count
        let mappedProgramVariableListCount = project?.variables.programVariableList.count
        XCTAssertEqual(cbProgramVariableListCount, mappedProgramVariableListCount)

        for vIdx in 0..<cbProgramVariableListCount! {
            let cbVar = cbProject.programVariableList?.userVariable?[vIdx]
            let mappedVar = project?.variables.programVariableList[vIdx] as? UserVariable

            XCTAssertEqual(cbVar?.value, mappedVar?.name)
        }
    }

    func testProgramVariableListsWithReferencesAreEqual() {
        let resolvedProject = createExtendedCBProjectWithReferencedUserVariable()
        let cbProject = resolvedProject.0
        let referencedUserVariable = resolvedProject.1

        let project = CBXMLMapping.mapCBProjectToProject(project: cbProject)

        XCTAssertEqual((project?.variables.programVariableList?[0] as? UserVariable)?.name, referencedUserVariable)
    }

    func testProgramListOfListsAreEqual() {
        let cbProject = createExtendedCBProject()
        let project = CBXMLMapping.mapCBProjectToProject(project: cbProject)

        let cbProgramListOfListsCount = cbProject.programListOfLists?.list?.count
        let mappedProgramListOfListsCount = project?.variables.programListOfLists.count
        XCTAssertEqual(cbProgramListOfListsCount, mappedProgramListOfListsCount)

        for vIdx in 0..<cbProgramListOfListsCount! {
            let cbVar = cbProject.programListOfLists?.list?[vIdx]
            let mappedVar = project?.variables.programListOfLists[vIdx] as? UserVariable

            XCTAssertEqual(cbVar?.name, mappedVar?.name)
        }
    }

    func testProgramListOfListsWithReferencesAreEqual() {
        let resolvedProject = createExtendedCBProjectWithReferencedUserVariable()
        let cbProject = resolvedProject.0
        let referencedUserVariable = resolvedProject.1

        let project = CBXMLMapping.mapCBProjectToProject(project: cbProject)

        XCTAssertEqual((project?.variables.programListOfLists?[0] as? UserVariable)?.name, referencedUserVariable)
    }

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

    func testUninitializedVariableListMapping() {
        var cbProject: CBProject?
        getProjectForXML2(xmlFile: "VariableMapping3") { project, error  in
            XCTAssertNil(error)
            cbProject = project
        }

        XCTAssertNotNil(cbProject)

        let project = CBXMLMapping.mapCBProjectToProject(project: cbProject)
        let spriteObject = project?.objectList[0] as? SpriteObject
        let formulaElement = (((spriteObject?.scriptList[0] as? Script)?.brickList[0] as? IfThenLogicBeginBrick)?.getFormulas()?.first)?.formulaTree

        XCTAssertNotNil(project?.variables.getUserListNamed(formulaElement?.value, for: spriteObject))
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
