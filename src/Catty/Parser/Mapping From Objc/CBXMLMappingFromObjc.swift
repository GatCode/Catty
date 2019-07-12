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

enum CBXMLMappingFromObjc {

    private static var userVariableList = [(UserVariable?, (Int, Int, Int))]() // contains local and global userVariables
    private static var objectList = [(SpriteObject?, (Int, Int, Int))]()
    private static var currentSerializationPosition = (0, 0, 0)
    private static var globalVariableList = [UserVariable]()
    private static var localVariableList = [(SpriteObject?, [[UserVariable?: (Int, Int, Int)]])]()

    static func mapProjectToCBProject(project: Project) -> CBProject? {

        CBXMLMappingFromObjc.userVariableList.removeAll()
        CBXMLMappingFromObjc.globalVariableList.removeAll()
        CBXMLMappingFromObjc.localVariableList.removeAll()

        var mappedProject = CBProject()

        // TODO: map header
        // TODO: map settings
        mappedProject.programVariableList = CBXMLMappingFromObjc.mapProgramVariableList(project: project)
        mappedProject.programListOfLists = CBXMLMappingFromObjc.mapProgramListOfLists(project: project)
        mappedProject.scenes = CBXMLMappingFromObjc.mapScenesToCBProject(project: project)

        return nil
    }
}

extension CBXMLMappingFromObjc {

    // MARK: - Map ProgramVariableList
    private static func mapProgramVariableList(project: Project) -> CBProgramVariableList {
        var mappedProgramVariables = [CBUserProgramVariable]()

        for variable in project.variables.programVariableList {
            if let variable = variable as? UserVariable {
                if let userVariable = mapUserVariable(project: project, userVariable: variable) {
                    mappedProgramVariables.append(CBUserProgramVariable(value: userVariable.value, reference: userVariable.reference))
                }

                if CBXMLMappingFromObjc.globalVariableList.contains(variable) == false {
                    CBXMLMappingFromObjc.globalVariableList.append(variable)
                }
            }
        }

        return CBProgramVariableList(userVariable: mappedProgramVariables)
    }

    // MARK: - Map ProgramListOfLists
    private static func mapProgramListOfLists(project: Project) -> CBProgramListOfLists {
        var mappedProgramVariables = [CBProgramList]()

        for variable in project.variables.programListOfLists {
            if let variable = variable as? UserVariable {
                if let userVariable = mapUserVariable(project: project, userVariable: variable) {
                    mappedProgramVariables.append(CBProgramList(name: userVariable.value, reference: userVariable.reference))
                }

                if CBXMLMappingFromObjc.globalVariableList.contains(variable) == false {
                    CBXMLMappingFromObjc.globalVariableList.append(variable)
                }
            }
        }

        return CBProgramListOfLists(list: mappedProgramVariables)
    }

    // MARK: - Map Scenes
    private static func mapScenesToCBProject(project: Project) -> [CBProjectScene] {
        var mappedScene = CBProjectScene()

        // TODO: map name
        mappedScene.objectList = mapObjectList(project: project)
        mappedScene.data = mapData(project: project)
        // TODO: map originalWidth
        // TODO: map originalHeight

        return [mappedScene]
    }

    private static func mapObjectList(project: Project) -> CBObjectList {
        var mappedObjectList = [CBObject]()

        for object in project.objectList {
            var mappedObject = CBObject()

            // TODO: map lookList
            // TODO: map soundList
            mappedObject.scriptList = mapScriptList(project: project, object: object as? SpriteObject)
            // TODO: map userBricks
            // TODO: map nfcTagList

            mappedObjectList.append(mappedObject)
            CBXMLMappingFromObjc.objectList.append((object as? SpriteObject, CBXMLMappingFromObjc.currentSerializationPosition))
            CBXMLMappingFromObjc.currentSerializationPosition.0 += 1
            CBXMLMappingFromObjc.currentSerializationPosition.1 = 0
        }

        return CBObjectList(object: mappedObjectList)
    }

    private static func mapScriptList(project: Project, object: SpriteObject?) -> CBScriptList? {
        guard let object = object else { return nil }
        var mappedScriptList = [CBScript]()

        for script in object.scriptList {
            var mappedScript = CBScript()

            mappedScript.brickList = mapBrickList(project: project, script: script as? Script, object: object)
            // TODO: map commentedOut
            // TODO: map isUserScript

            mappedScriptList.append(mappedScript)
            CBXMLMappingFromObjc.currentSerializationPosition.1 += 1
            CBXMLMappingFromObjc.currentSerializationPosition.2 = 0
        }

        return CBScriptList(script: mappedScriptList)
    }

    private static func mapBrickList(project: Project, script: Script?, object: SpriteObject) -> CBBrickList? {
        guard let script = script else { return nil }
        var mappedBrickList = [CBBrick]()

        for brick in script.brickList {
            if let type = (brick as? Brick)?.brickTitle {
                var mappedBrick = CBBrick()

                // MARK: Variable Bricks
                if type.hasPrefix(kLocalizedSetVariable) {
                    let brick = brick as? SetVariableBrick
                    mappedBrick.name = kSetVariableBrick
                    mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.variableFormula])
                    let uVar = mapUserVariableWithLocalCheck(project: project, userVariable: brick?.userVariable, object: object)
                    mappedBrick.userVariable = uVar?.value
                    mappedBrick.userVariableReference = uVar?.reference
                } else if type.hasPrefix(kLocalizedChangeVariable) {
                    let brick = brick as? ChangeVariableBrick
                    mappedBrick.name = kChangeVariableBrick
                    mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.variableFormula])
                    let uVar = mapUserVariableWithLocalCheck(project: project, userVariable: brick?.userVariable, object: object)
                    mappedBrick.userVariable = uVar?.value
                    mappedBrick.userVariableReference = uVar?.reference
                } else if type.hasPrefix(kLocalizedShowVariable) {
                    let brick = brick as? ShowTextBrick
                    mappedBrick.name = kShowTextBrick
                    mappedBrick.xPosition = mapFormula(formula: brick?.xFormula)
                    mappedBrick.yPosition = mapFormula(formula: brick?.yFormula)
                    let uVar = mapUserVariableWithLocalCheck(project: project, userVariable: brick?.userVariable, object: object)
                    mappedBrick.userVariable = uVar?.value
                    mappedBrick.userVariableReference = uVar?.reference
                } else if type.hasPrefix(kLocalizedHideVariable) {
                    let brick = brick as? HideTextBrick
                    mappedBrick.name = kHideTextBrick
                    let uVar = mapUserVariableWithLocalCheck(project: project, userVariable: brick?.userVariable, object: object)
                    mappedBrick.userVariable = uVar?.value
                    mappedBrick.userVariableReference = uVar?.reference
                } else if type.hasPrefix(kLocalizedUserListAdd) {
                    let brick = brick as? AddItemToUserListBrick
                    mappedBrick.name = kAddItemToUserListBrick
                    mappedBrick.formulaList = mapFormulaList(formulas: [brick?.listFormula])
                    let uVar = mapUserVariableWithLocalCheck(project: project, userVariable: brick?.userList, object: object)
                    mappedBrick.userList = uVar?.value
                    mappedBrick.userVariableReference = uVar?.reference
                } else if type.hasPrefix(kLocalizedUserListDeleteItemFrom) {
                    let brick = brick as? DeleteItemOfUserListBrick
                    mappedBrick.name = kDeleteItemOfUserListBrick
                    mappedBrick.formulaList = mapFormulaList(formulas: [brick?.listFormula])
                    let uVar = mapUserVariableWithLocalCheck(project: project, userVariable: brick?.userList, object: object)
                    mappedBrick.userList = uVar?.value
                    mappedBrick.userVariableReference = uVar?.reference
                } else if type.hasPrefix(kLocalizedUserListInsert) {
                    let brick = brick as? InsertItemIntoUserListBrick
                    mappedBrick.name = kInsertItemIntoUserListBrick
                    mappedBrick.formulaList = mapFormulaList(formulas: [brick?.elementFormula])
                    mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.index])
                    let uVar = mapUserVariableWithLocalCheck(project: project, userVariable: brick?.userList, object: object)
                    mappedBrick.userList = uVar?.value
                    mappedBrick.userVariableReference = uVar?.reference
                } else if type.hasPrefix(kLocalizedUserListReplaceItemInList) {
                    let brick = brick as? ReplaceItemInUserListBrick
                    mappedBrick.name = kReplaceItemInUserListBrick
                    mappedBrick.formulaList = mapFormulaList(formulas: [brick?.elementFormula])
                    mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.index])
                    let uVar = mapUserVariableWithLocalCheck(project: project, userVariable: brick?.userList, object: object)
                    mappedBrick.userList = uVar?.value
                    mappedBrick.userVariableReference = uVar?.reference
                } else {
                    print("nononono")
                }

                mappedBrickList.append(mappedBrick)
            }
            CBXMLMappingFromObjc.currentSerializationPosition.2 += 1
        }

        return CBBrickList(brick: mappedBrickList)
    }

    private static func mapFormulaList(formulas: [Formula?]) -> CBFormulaList? {
        var mappedFormulas = [CBFormula]()

        for formula in formulas {
            if let mappedFormula = mapFormula(formula: formula) {
                mappedFormulas.append(mappedFormula)
            }
        }

        return CBFormulaList(formula: mappedFormulas)
    }

    private static func mapFormula(formula: Formula?) -> CBFormula? {
        guard let formula = formula else { return nil }
        guard let parentElement = formula.formulaTree else { return nil }

        let type = parentElement.string(for: parentElement.type)
        let value = parentElement.value
        let category = "" // TODO???
        let left = mapFormulaChild(formulaElement: parentElement.leftChild)
        let right = mapFormulaChild(formulaElement: parentElement.rightChild)

        let mappedFormula = CBFormula(type: type, value: value, category: category, leftChild: left, rightChild: right)

        return mappedFormula
    }

    private static func mapFormulaChild(formulaElement: FormulaElement?) -> CBLRChild? {
        guard let formulaElement = formulaElement else { return nil }

        var mappedChild = CBLRChild()
        mappedChild.type = formulaElement.string(for: formulaElement.type)
        mappedChild.value = formulaElement.value
        mappedChild.leftChild = [mapFormulaChild(formulaElement: formulaElement.leftChild)]
        mappedChild.rightChild = [mapFormulaChild(formulaElement: formulaElement.rightChild)]

        return mappedChild
    }

    private static func mapUserVariableWithLocalCheck(project: Project, userVariable: UserVariable?, object: SpriteObject) -> CBUserVariable? {
        guard let userVariable = userVariable else { return nil }

        if globalVariableList.contains(userVariable) == false {
            for (index, element) in CBXMLMappingFromObjc.localVariableList.enumerated() where element.0 == object {
                if CBXMLMappingFromObjc.localVariableList[index].1.contains(where: { $0.contains(where: { $0.key == userVariable }) }) == false {
                    CBXMLMappingFromObjc.localVariableList[index].1.append([userVariable: CBXMLMappingFromObjc.currentSerializationPosition])
                }
                return mapUserVariable(project: project, userVariable: userVariable)
            }
            CBXMLMappingFromObjc.localVariableList.append((object, [[userVariable: CBXMLMappingFromObjc.currentSerializationPosition]]))
        }

        return mapUserVariable(project: project, userVariable: userVariable)
    }

    private static func mapUserVariable(project: Project, userVariable: UserVariable?) -> CBUserVariable? {
        guard let userVariable = userVariable else { return nil }

        if CBXMLMappingFromObjc.userVariableList.contains(where: { $0.0 == userVariable }) == false {
            CBXMLMappingFromObjc.userVariableList.append((userVariable, CBXMLMappingFromObjc.currentSerializationPosition))
            return(CBUserVariable(value: userVariable.name, reference: nil))
        }

        return CBUserVariable(value: nil, reference: resolveUserVariablePath(project: project, userVariable: userVariable))
    }

    private static func resolveUserVariablePath(project: Project, userVariable: UserVariable?) -> String? {
        let currentObjectPos = CBXMLMappingFromObjc.currentSerializationPosition.0
        let currentScriptPos = CBXMLMappingFromObjc.currentSerializationPosition.1

        if let referencedUserVariable = CBXMLMappingFromObjc.userVariableList.first(where: { $0.0 == userVariable }) {
            let referencedPosition = referencedUserVariable.1

            if referencedPosition.0 == currentObjectPos {
                if referencedPosition.1 == currentScriptPos {
                    return "../../" + (referencedPosition.2 == 0 ? "brick/" : "brick[\(referencedPosition.2 + 1)]/") + "userVariable"
                } else {
                    let scrString = referencedPosition.1 == 0 ? "script/" : "script[\(referencedPosition.1 + 1)]/"
                    let brString = referencedPosition.2 == 0 ? "brick/" : "brick[\(referencedPosition.2 + 1)]/"
                    return "../../../.." + scrString + "brickList/" + brString + "userVariable"
                }
            } else {
                let objString = referencedPosition.0 == 0 ? "object/" : "object[\(referencedPosition.0 + 1)]/"
                let scrString = referencedPosition.1 == 0 ? "script/" : "script[\(referencedPosition.1 + 1)]/"
                let brString = referencedPosition.2 == 0 ? "brick/" : "brick[\(referencedPosition.2 + 1)]/"
                return "../../../../../../" + objString + "scriptList/" + scrString + "brickList/" + brString + "userVariable"
            }
        }

        return nil
    }

    private static func mapData(project: Project) -> CBProjectData {
        var mappedData = CBProjectData()

        mappedData.objectVariableList = mapObjectVariableList(project: project)
        mappedData.objectListOfList = mapObjectListOfLists(project: project)
        // TODO: map userBrickVariableList

        return mappedData
    }

    private static func mapObjectVariableList(project: Project) -> CBObjectVariableList {

        var mappedEntries = [CBObjectVariableEntry]()

        for index in 0..<project.variables.objectVariableList.count() {
            mappedEntries.append(mapObjectVariableListEntry(project: project, referencedIndex: index))
        }

        return CBObjectVariableList(entry: mappedEntries)
    }

    private static func mapObjectListOfLists(project: Project) -> CBObjectListofList {

        var mappedEntries = [CBObjectListOfListEntry]()

        for index in 0..<project.variables.objectListOfLists.count() {
            mappedEntries.append(mapObjectListOfListsEntry(project: project, referencedIndex: index))
        }

        return CBObjectListofList(entry: mappedEntries)
    }

    private static func mapObjectVariableListEntry(project: Project, referencedIndex: UInt) -> CBObjectVariableEntry {
        let referencedObject = project.variables.objectVariableList.key(at: referencedIndex)
        let referencedVariableList = project.variables.objectVariableList.object(at: referencedIndex)
        let spriteObject = referencedObject as? SpriteObject
        let userVariableList = referencedVariableList as? [UserVariable]

        let object = resolveObjectPath(project: project, object: spriteObject)
        let list = mapObjectVariableListEntryList(project: project, list: userVariableList, object: spriteObject, objectPath: object)

        return CBObjectVariableEntry(object: object, list: list)
    }

    private static func mapObjectListOfListsEntry(project: Project, referencedIndex: UInt) -> CBObjectListOfListEntry {
        let referencedObject = project.variables.objectListOfLists.key(at: referencedIndex)
        let referencedVariableList = project.variables.objectListOfLists.object(at: referencedIndex)
        let spriteObject = referencedObject as? SpriteObject
        let userVariableList = referencedVariableList as? [UserVariable]

        let object = resolveObjectPath(project: project, object: spriteObject)
        let list = mapObjectVariableListEntryList(project: project, list: userVariableList, object: spriteObject, objectPath: object)

        return CBObjectListOfListEntry(object: object, list: list)
    }

    private static func resolveObjectPath(project: Project, object: SpriteObject?) -> String? {
        guard let object = object else { return nil }

        if let referencedUserVariable = CBXMLMappingFromObjc.objectList.first(where: { $0.0 == object }) {
            let referencedPosition = referencedUserVariable.1
            return "../../../../objectList/" + (referencedPosition.0 == 0 ? "object" : "object[\(referencedPosition.0 + 1)]")
        }

        return nil
    }

    private static func mapObjectVariableListEntryList(project: Project, list: [UserVariable]?, object: SpriteObject?, objectPath: String?) -> [CBUserVariable]? {
        guard let list = list else { return nil }
        guard let objectPath = objectPath else { return nil }
        var mappedUserVariables = [CBUserVariable]()

        for userVariable in list {
            if CBXMLMappingFromObjc.globalVariableList.contains(userVariable) == false {
                if let referencedDictionary = CBXMLMappingFromObjc.localVariableList.first(where: { $0.0 == object }) {
                    if let referencedArray = referencedDictionary.1.first(where: { $0[userVariable] != nil }) {
                        if let referencedUserVariablePosition = referencedArray.first(where: { $0.key == userVariable }) {
                            let scrString = referencedUserVariablePosition.1.1 == 0 ? "script/" : "script[\(referencedUserVariablePosition.1.1 + 1)]/"
                            let brString = referencedUserVariablePosition.1.2 == 0 ? "brick/" : "brick[\(referencedUserVariablePosition.1.2 + 1)]/"
                            let referenceString = "../" + objectPath + "/scriptList/" + scrString + "brickList/" + brString + "userVariable"
                            mappedUserVariables.append(CBUserVariable(value: "userVariable", reference: referenceString))
                        }
                    }
                }
            } else {
                if let referencedUserVariable = CBXMLMappingFromObjc.userVariableList.first(where: { $0.0 == userVariable }) {
                    let referencedPosition = referencedUserVariable.1
                    let objString = referencedPosition.0 == 0 ? "object/" : "object[\(referencedPosition.0 + 1)]/"
                    let scrString = referencedPosition.1 == 0 ? "script/" : "script[\(referencedPosition.1 + 1)]/"
                    let brString = referencedPosition.2 == 0 ? "brick/" : "brick[\(referencedPosition.2 + 1)]/"
                    let referenceString = "../../../../../objectList/" + objString + "scriptList/" + scrString + "brickList/" + brString + "userVariable"
                    mappedUserVariables.append(CBUserVariable(value: "userVariable", reference: referenceString))
                }
            }
        }

        return mappedUserVariables
    }
}
