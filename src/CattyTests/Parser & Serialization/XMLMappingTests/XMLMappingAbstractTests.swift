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

class XMLMappingAbstractTests: XMLAbstractTest {

    func createBasicCBProject() -> CBProject {
        let sceneList = [CBProjectScene(name: "Scene1")]
        let objectList = CBObjectList(objects: [CBObject(name: "Object1"), CBObject(name: "Object2")])
        let lookList = CBLookList(looks: [CBLook(name: "Look1", fileName: "File1"), CBLook(name: "Look2", fileName: "File1")])
        let soundList = CBSoundList(sounds: [CBSound(fileName: "File1", name: "Sound1", reference: "../ref1"), CBSound(fileName: "File2", name: "Sound2", reference: "../ref2")])
        let scriptList = CBScriptList(scripts: [CBScript(type: "Script"), CBScript(type: "BroadcastScript")])
        let brickList = CBBrickList(bricks: [CBBrick(type: "SetVariableBrick"), CBBrick(type: "SetVariableBrick")])
        let userVariable = "UVar1"
        let userList = "UList1"

        var cbProject = CBProject()
        cbProject.scenes = sceneList
        for sceneIdx in 0..<(cbProject.scenes?.count)! {
            cbProject.scenes?[sceneIdx].objectList = objectList
            for objectIdx in 0..<(cbProject.scenes?[sceneIdx].objectList?.objects?.count)! {
                cbProject.scenes?[sceneIdx].objectList?.objects?[objectIdx].lookList = lookList
                cbProject.scenes?[sceneIdx].objectList?.objects?[objectIdx].soundList = soundList
                cbProject.scenes?[sceneIdx].objectList?.objects?[objectIdx].scriptList = scriptList
                for scriptIdx in 0..<(cbProject.scenes?[sceneIdx].objectList?.objects?[objectIdx].scriptList?.scripts?.count)! {
                    cbProject.scenes?[sceneIdx].objectList?.objects?[objectIdx].scriptList?.scripts?[scriptIdx].brickList = brickList
                    for brickIdx in 0..<(cbProject.scenes?[sceneIdx].objectList?.objects?[objectIdx].scriptList?.scripts?[scriptIdx].brickList?.bricks?.count)! {
                        cbProject.scenes?[sceneIdx].objectList?.objects?[objectIdx].scriptList?.scripts?[scriptIdx].brickList?.bricks?[brickIdx].userVariable = userVariable
                        cbProject.scenes?[sceneIdx].objectList?.objects?[objectIdx].scriptList?.scripts?[scriptIdx].brickList?.bricks?[brickIdx].userList = userList
                    }
                }
            }
        }

        return cbProject
    }

    func createExtendedCBProject() -> CBProject {
        let programVariableListEntries = [CBUserProgramVariable(value: "Value1"), CBUserProgramVariable(value: "Value2")]
        let programVariableList = CBProgramVariableList(userVariable: programVariableListEntries)
        let programListOfListsEntries = [CBProgramList(value: "Value1"), CBProgramList(value: "Value2")]
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
        let referencedVariableName = cbProject.scenes?[0].objectList?.objects?[0].scriptList?.scripts?[0].brickList?.bricks?[0].userVariable

        let programVariableList = CBProgramVariableList(userVariable: [CBUserProgramVariable(reference: referencedVariable)])
        let programListOfLists = CBProgramListOfLists(list: [CBProgramList(reference: referencedList)])

        cbProject.programVariableList = programVariableList
        cbProject.programListOfLists = programListOfLists

        return (cbProject, referencedVariableName!)
    }
}
