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

    func testMapObjectList() {
        let cbProject = createBasicCBProject()
        var project = CBXMLMappingToObjc.mapCBProjectToProject(project: cbProject)

        if project != nil {
            let mappedObjectList = CBXMLMappingToObjc.mapObjectList(project: cbProject, currentProject: &project!)
            XCTAssertEqual(cbProject.scenes?.first?.objectList?.objects?.count, mappedObjectList?.count)

            for (index, object) in mappedObjectList!.enumerated() {
                if let object = object as? SpriteObject {
                    XCTAssertEqual(object.name, cbProject.scenes?.first?.objectList?.objects?[index].name)
                    XCTAssertEqual(object.lookList.count, cbProject.scenes?.first?.objectList?.objects?[index].lookList?.looks?.count)
                    XCTAssertEqual(object.soundList.count, cbProject.scenes?.first?.objectList?.objects?[index].soundList?.sounds?.count)
                    XCTAssertEqual(object.scriptList.count, cbProject.scenes?.first?.objectList?.objects?[index].scriptList?.scripts?.count)
                } else {
                    XCTAssert(false)
                }
            }
        } else {
            XCTAssert(false)
        }
    }

    // MARK: - Object Mapping
    func testObjectsAreEqual() {
        var cbProject = createBasicCBProject()
        let project = CBXMLMappingToObjc.mapCBProjectToProject(project: cbProject)

        let cbObjectList = cbProject.scenes?[0].objectList?.objects
        let mappedObjectList = project?.objectList

        XCTAssertEqual(cbObjectList?.count, mappedObjectList?.count)
        XCTAssertEqual(cbObjectList?[0].name, (mappedObjectList?[0] as? SpriteObject)?.name)
        XCTAssertEqual(cbObjectList?[1].name, (mappedObjectList?[1] as? SpriteObject)?.name)
    }

    // MARK: - Look Mapping
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

    func testMapLookList() {
        let looks = [CBLook(name: "L1", fileName: "file1"), CBLook(name: "L2", fileName: "file2")]
        let mappedLooks = CBXMLMappingToObjc.mapLookList(lookList: CBLookList(looks: looks)) as? [Look]

        XCTAssertEqual(looks.count, mappedLooks?.count)

        for (index, look) in looks.enumerated() {
            if let mappedLooks = mappedLooks {
                XCTAssertEqual(look.name, mappedLooks[index].name)
                XCTAssertEqual(look.fileName, mappedLooks[index].fileName)
            } else {
                XCTAssert(false)
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

    // MARK: - Sound Mapping
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

    func testAllocSound() {
        let sound = CBSound(fileName: "file1", name: "S1", reference: nil)
        let mappedSound = CBXMLMappingToObjc.allocSound(name: "S1", filename: "file1")

        XCTAssertEqual(sound.name, mappedSound?.name)
        XCTAssertEqual(sound.fileName, mappedSound?.fileName)
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

    // MARK: - Script Mapping
    func testMapScriptList() {
        let cbProject = createBasicCBProject()
        let project = CBXMLMappingToObjc.mapCBProjectToProject(project: cbProject)
        let cbObjects = cbProject.scenes?.first?.objectList?.objects
        var spriteObject = project?.objectList.firstObject as! SpriteObject

        let mappedScriptList = CBXMLMappingToObjc.mapScriptList(object: cbObjects?.first, objectList: cbObjects, project: cbProject, currentObject: &spriteObject)

        XCTAssertEqual(cbObjects?.first?.scriptList?.scripts?.first?.brickList?.bricks?.count, (mappedScriptList?.firstObject as? Script)?.brickList.count)
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

    // MARK: - Brick Mapping
    func testMapBrickList() {
        let cbProject = createExtendedCBProject()
        let cbObjectList = cbProject.scenes?.first?.objectList?.objects
        let cbObject = cbObjectList?.first
        let cbScript = cbObject?.scriptList?.scripts?.first
        let project = CBXMLMappingToObjc.mapCBProjectToProject(project: cbProject)
        var currentObject = project?.objectList.firstObject as! SpriteObject
        var currentScript = currentObject.scriptList.firstObject as? Script

        let mappedBrickList = CBXMLMappingToObjc.mapBrickList(script: cbScript, objectList: cbObjectList, object: cbObject, project: cbProject, currScript: &currentScript, currObject: &currentObject)

        XCTAssertEqual(cbScript?.brickList?.bricks?.count, mappedBrickList?.count)
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

    func testMapGlideDestinations() {
        let xDest = "-123"
        let yDest = "567"

        let xDestFormula = CBFormulaList(formulas: [CBFormula(type: "NUMBER", value: xDest, category: nil, leftChild: nil, rightChild: nil)])
        let yDestFormula = CBFormulaList(formulas: [CBFormula(type: "NUMBER", value: yDest, category: nil, leftChild: nil, rightChild: nil)])
        let cbBrick = CBBrick(type: "GlideToBrick", xDestination: xDestFormula, yDestination: yDestFormula)

        let mappedXDestination = CBXMLMappingToObjc.mapGlideDestinations(input: cbBrick, xDestination: true)
        let mappedYDestination = CBXMLMappingToObjc.mapGlideDestinations(input: cbBrick, xDestination: false)

        XCTAssertEqual(xDest, (mappedXDestination?.firstObject as? Formula)?.formulaTree.value)
        XCTAssertEqual(yDest, (mappedYDestination?.firstObject as? Formula)?.formulaTree.value)
    }

    func testMapXYDestinationsToBrick() {
        let xDest = "-123"
        let yDest = "567"

        let xDestFormula = CBFormulaList(formulas: [CBFormula(type: "NUMBER", value: xDest, category: nil, leftChild: nil, rightChild: nil)])
        let yDestFormula = CBFormulaList(formulas: [CBFormula(type: "NUMBER", value: yDest, category: nil, leftChild: nil, rightChild: nil)])
        let cbBrick = CBBrick(type: "GlideToBrick", xDestination: xDestFormula, yDestination: yDestFormula)

        let mappedDestinations = CBXMLMappingToObjc.mapXYDestinationsToBrick(input: cbBrick)

        XCTAssertEqual(mappedDestinations?.count, 2)
        XCTAssertEqual(xDest, (mappedDestinations?[0] as? Formula)?.formulaTree.value)
        XCTAssertEqual(yDest, (mappedDestinations?[1] as? Formula)?.formulaTree.value)
    }

    // MARK: - Formula Mapping
    func testMapCBFormulaToFormula() {
        let one = "1"
        let two = "2"
        let cat = "cat"
        let root = FormulaElement()
        let rightChild = CBLRChild(type: root.string(for: ElementType.NUMBER), value: "rightChildValue")

        let formula1 = CBFormula(type: "NUMBER", value: one, category: cat, leftChild: nil, rightChild: rightChild)
        let formula2 = CBFormula(type: "NUMBER", value: two, category: cat, leftChild: nil, rightChild: rightChild)

        let firstMappedFormula = CBXMLMappingToObjc.mapCBFormulaToFormula(input: formula1)
        let secondMappedFormula = CBXMLMappingToObjc.mapCBFormulaToFormula(input: formula2)

        XCTAssertEqual(one, firstMappedFormula.formulaTree.value)
        XCTAssertEqual(two, secondMappedFormula.formulaTree.value)
        XCTAssertEqual(cat, secondMappedFormula.category)
        XCTAssertEqual(nil, secondMappedFormula.formulaTree.leftChild)
        XCTAssertEqual(rightChild.value, secondMappedFormula.formulaTree.rightChild.value)
    }

    func testMapCBLRChildToFormulaTree() {
        let root = FormulaElement()

        let leftChild = CBLRChild(type: root.string(for: ElementType.FUNCTION), value: "leftChildValue")
        let rightChild = CBLRChild(type: root.string(for: ElementType.NUMBER), value: "rightChildValue")
        let element = CBLRChild(type: root.string(for: ElementType.STRING), value: "value", leftChild: [leftChild], rightChild: [rightChild])

        let mappedFormulaElement = CBXMLMappingToObjc.mapCBLRChildToFormulaTree(input: element, tree: root)
        XCTAssertEqual(element.type, root.string(for: (mappedFormulaElement?.type)!))
        XCTAssertEqual(element.value, mappedFormulaElement?.value)
        XCTAssertEqual(root, mappedFormulaElement?.parent)

        XCTAssertNotNil(mappedFormulaElement?.leftChild)
        XCTAssertEqual(leftChild.type, root.string(for: (mappedFormulaElement?.leftChild.type)!))
        XCTAssertEqual(leftChild.value, mappedFormulaElement?.leftChild.value)
        XCTAssertEqual(mappedFormulaElement, mappedFormulaElement?.leftChild.parent)

        XCTAssertNotNil(mappedFormulaElement?.rightChild)
        XCTAssertEqual(rightChild.type, root.string(for: (mappedFormulaElement?.rightChild.type)!))
        XCTAssertEqual(rightChild.value, mappedFormulaElement?.rightChild.value)
        XCTAssertEqual(mappedFormulaElement, mappedFormulaElement?.rightChild.parent)
    }

    // MARK: - UserVariable Mapping
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

    func testAllocUserVariable() {
        let uVarName = "UVar"
        let mappedUVar = CBXMLMappingToObjc.allocUserVariable(name: uVarName, isList: false)
        let mappedUList = CBXMLMappingToObjc.allocUserVariable(name: uVarName, isList: true)

        XCTAssertEqual(uVarName, mappedUVar.name)
        XCTAssertEqual(uVarName, mappedUList.name)
        XCTAssertEqual(mappedUVar.name, mappedUList.name)
        XCTAssertNotEqual(mappedUVar.isList, mappedUList.isList)
    }

    func testAllocLocalUserVariable() {
        let uVarName = "UVarLocal"
        let mappedUVar = CBXMLMappingToObjc.allocLocalUserVariable(name: uVarName, isList: false)
        let mappedUList = CBXMLMappingToObjc.allocLocalUserVariable(name: uVarName, isList: true)

        XCTAssertEqual(uVarName, mappedUVar.name)
        XCTAssertEqual(uVarName, mappedUList.name)
        XCTAssertEqual(mappedUVar.name, mappedUList.name)
        XCTAssertNotEqual(mappedUVar.isList, mappedUList.isList)
    }

    // MARK: - Broadcast Mapping
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

    // MARK: - Extract Numbers
    func testExtractAbstractNumbersFrom() {
        let cbProject = createExtendedCBProject()
        let cbObject = cbProject.scenes?.first?.objectList?.objects?.first

        let refString = "../../../objectList/object/scriptList/script/brickList/brick/helloWorld"
        let extracedNumbers = CBXMLMappingToObjc.extractAbstractNumbersFrom(reference: refString, project: cbProject)
        XCTAssertEqual(0, extracedNumbers.0)
        XCTAssertEqual(0, extracedNumbers.1)
        XCTAssertEqual(0, extracedNumbers.2)

        let refString2 = "../../../scriptList/script/brickList/brick/helloWorld"
        let extracedNumbers2 = CBXMLMappingToObjc.extractAbstractNumbersFrom(object: cbObject!, reference: refString2, project: cbProject)
        XCTAssertEqual(0, extracedNumbers2.0)
        XCTAssertEqual(0, extracedNumbers2.1)

        let refString3 = "../../../objectList/object[1]/scriptList/script[1]/brickList/brick[1]/helloWorld[1]"
        let extracedNumbers3 = CBXMLMappingToObjc.extractAbstractNumbersFrom(reference: refString3, project: cbProject)
        XCTAssertEqual(0, extracedNumbers3.0)
        XCTAssertEqual(0, extracedNumbers3.1)
        XCTAssertEqual(0, extracedNumbers3.2)
    }

    func testExtractNumberInBacesFrom() {
        let refNumber1 = 1
        let refNumber2 = 12
        let refNumber3 = 123
        let extractedNumber1 = CBXMLMappingToObjc.extractNumberInBacesFrom(string: "hello[\(refNumber1)]world")
        let extractedNumber2 = CBXMLMappingToObjc.extractNumberInBacesFrom(string: "hello[\(refNumber2)]world")
        let extractedNumber3 = CBXMLMappingToObjc.extractNumberInBacesFrom(string: "hello[\(refNumber3)]world")

        XCTAssertEqual(refNumber1, extractedNumber1 + 1)
        XCTAssertEqual(refNumber2, extractedNumber2 + 1)
        XCTAssertEqual(refNumber3, extractedNumber3 + 1)
    }
}
