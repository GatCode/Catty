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

    private static var userVariableList = [(UserVariable?, (Int, Int, Int))]()
    private static var objectList = [(SpriteObject?, (Int, Int, Int))]()
    private static var currentSerializationPosition = (0, 0, 0)

    static func mapProjectToCBProject(project: Project) -> CBProject? {

        CBXMLMappingFromObjc.userVariableList.removeAll()

        var mappedProject = CBProject()

        // map header
        // map settings
        mappedProject.scenes = CBXMLMappingFromObjc.mapScenesToCBProject(project: project)
        mappedProject.programVariableList = CBXMLMappingFromObjc.mapProgramVariableList(project: project)
        mappedProject.programListOfLists = CBXMLMappingFromObjc.mapProgramListOfLists(project: project)

        return nil
    }
}

extension CBXMLMappingFromObjc {

    // MARK: - Map Scenes
    private static func mapScenesToCBProject(project: Project) -> [CBProjectScene] {
        var mappedScene = CBProjectScene()

        // map name
        mappedScene.objectList = mapObjectList(project: project)
        mappedScene.data = mapData(project: project)
        // map originalWidth
        // map originalHeight

        return [mappedScene]
    }

    private static func mapObjectList(project: Project) -> CBObjectList {
        var mappedObjectList = [CBObject]()

        for object in project.objectList {
            var mappedObject = CBObject()

            // map lookList
            // map soundList
            mappedObject.scriptList = mapScriptList(project: project, object: object as? SpriteObject)
            // map userBricks
            // map nfcTagList

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

            mappedScript.brickList = mapBrickList(project: project, script: script as? Script)
            // map commentedOut
            // map isUserScript

            mappedScriptList.append(mappedScript)
            CBXMLMappingFromObjc.currentSerializationPosition.1 += 1
            CBXMLMappingFromObjc.currentSerializationPosition.2 = 0
        }

        return CBScriptList(script: mappedScriptList)
    }

    private static func mapBrickList(project: Project, script: Script?) -> CBBrickList? {
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
                    let uVar = mapUserVariable(project: project, userVariable: brick?.userVariable)
                    mappedBrick.userVariable = uVar?.value
                    mappedBrick.userVariableReference = uVar?.reference
                } else if type.hasPrefix(kLocalizedChangeVariable) {
                    let brick = brick as? ChangeVariableBrick
                    mappedBrick.name = kChangeVariableBrick
                    mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.variableFormula])
                    let uVar = mapUserVariable(project: project, userVariable: brick?.userVariable)
                    mappedBrick.userVariable = uVar?.value
                    mappedBrick.userVariableReference = uVar?.reference
                } else if type.hasPrefix(kLocalizedShowVariable) {
                    let brick = brick as? ShowTextBrick
                    mappedBrick.name = kShowTextBrick
                    mappedBrick.xPosition = mapFormula(formula: brick?.xFormula)
                    mappedBrick.yPosition = mapFormula(formula: brick?.yFormula)
                    let uVar = mapUserVariable(project: project, userVariable: brick?.userVariable)
                    mappedBrick.userVariable = uVar?.value
                    mappedBrick.userVariableReference = uVar?.reference
                } else if type.hasPrefix(kLocalizedHideVariable) {
                    let brick = brick as? HideTextBrick
                    mappedBrick.name = kHideTextBrick
                    let uVar = mapUserVariable(project: project, userVariable: brick?.userVariable)
                    mappedBrick.userVariable = uVar?.value
                    mappedBrick.userVariableReference = uVar?.reference
                } else if type.hasPrefix(kLocalizedUserListAdd) {
                    let brick = brick as? AddItemToUserListBrick
                    mappedBrick.name = kAddItemToUserListBrick
                    mappedBrick.formulaList = mapFormulaList(formulas: [brick?.listFormula])
                    let uVar = mapUserVariable(project: project, userVariable: brick?.userList)
                    mappedBrick.userList = uVar?.value
                    mappedBrick.userVariableReference = uVar?.reference
                } else if type.hasPrefix(kLocalizedUserListDeleteItemFrom) {
                    let brick = brick as? DeleteItemOfUserListBrick
                    mappedBrick.name = kDeleteItemOfUserListBrick
                    mappedBrick.formulaList = mapFormulaList(formulas: [brick?.listFormula])
                    let uVar = mapUserVariable(project: project, userVariable: brick?.userList)
                    mappedBrick.userList = uVar?.value
                    mappedBrick.userVariableReference = uVar?.reference
                } else if type.hasPrefix(kLocalizedUserListInsert) {
                    let brick = brick as? InsertItemIntoUserListBrick
                    mappedBrick.name = kInsertItemIntoUserListBrick
                    mappedBrick.formulaList = mapFormulaList(formulas: [brick?.elementFormula])
                    mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.index])
                    let uVar = mapUserVariable(project: project, userVariable: brick?.userList)
                    mappedBrick.userList = uVar?.value
                    mappedBrick.userVariableReference = uVar?.reference
                } else if type.hasPrefix(kLocalizedUserListReplaceItemInList) {
                    let brick = brick as? ReplaceItemInUserListBrick
                    mappedBrick.name = kReplaceItemInUserListBrick
                    mappedBrick.formulaList = mapFormulaList(formulas: [brick?.elementFormula])
                    mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.index])
                    let uVar = mapUserVariable(project: project, userVariable: brick?.userList)
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

        if let referencedUserVariable = CBXMLMappingFromObjc.userVariableList.first(where: {$0.0 == userVariable} ) {
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
        // map objectListOfList
        // map userBrickVariableList

        return mappedData
    }

    private static func mapObjectVariableList(project: Project) -> CBObjectVariableList {

        var mappedEntries = [CBObjectVariableEntry]()

        for index in 0..<project.variables.objectVariableList.count() {
            mappedEntries.append(mapObjectVariableListEntry(project: project, referencedIndex: index))
        }

        return CBObjectVariableList(entry: mappedEntries)
    }

    private static func mapObjectVariableListEntry(project: Project, referencedIndex: UInt) -> CBObjectVariableEntry {
        let referencedObject = project.variables.objectVariableList.key(at: referencedIndex)
        let referencedVariableList = project.variables.objectVariableList.object(at: referencedIndex)

        let object = resolveObjectPath(project: project, object: referencedObject as? SpriteObject)
        let list = mapObjectVariableListEntryList(project: project, list: referencedVariableList as? [UserVariable])

        return CBObjectVariableEntry(object: object, list: list)
    }

    private static func resolveObjectPath(project: Project, object: SpriteObject?) -> String? {
        guard let object = object else { return nil }

        if let referencedUserVariable = CBXMLMappingFromObjc.objectList.first(where: {$0.0 == object} ) {
            let referencedPosition = referencedUserVariable.1
            return "../../../../objectList/" + (referencedPosition.0 == 0 ? "object" : "object[\(referencedPosition.0 + 1)]")
        }

        return nil
    }

    private static func mapObjectVariableListEntryList(project: Project, list: [UserVariable]?) -> [CBUserVariable]? {
        guard let list = list else { return nil }

        // TODO: map list - keep an eye on local variables!!!

        return nil
    }

    // MARK: - Map ProgramVariableList
    private static func mapProgramVariableList(project: Project) -> CBProgramVariableList {
        var mappedProgramVariables = [CBUserProgramVariable]()

        for variable in project.variables.programVariableList {
            if let userVariable = mapUserVariable(project: project, userVariable: variable as? UserVariable) {
                mappedProgramVariables.append(CBUserProgramVariable(value: userVariable.value, reference: userVariable.reference))
            }
        }

        return CBProgramVariableList(userVariable: mappedProgramVariables)
    }

    // MARK: - Map ProgramListOfLists
    private static func mapProgramListOfLists(project: Project) -> CBProgramListOfLists {
        var mappedProgramVariables = [CBProgramList]()

        for variable in project.variables.programListOfLists {
            if let userVariable = mapUserVariable(project: project, userVariable: variable as? UserVariable) {
                mappedProgramVariables.append(CBProgramList(name: userVariable.value, reference: userVariable.reference))
            }
        }

        return CBProgramListOfLists(list: mappedProgramVariables)
    }
}
