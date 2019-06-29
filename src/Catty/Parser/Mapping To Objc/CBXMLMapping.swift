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

struct CBXMLMapping {
    static func mapCBProjectToProject(project: CBProject?) -> Project? {

        var mappedProject = Project()

        // IMPORTANT: DO NOT CHANGE ORDER HERE!!
        mappedProject.header = CBXMLMapping.mapHeaderToHeader(input: project?.header)

        if let mappedObjectList = CBXMLMapping.mapObjectList(project: project, currentProject: &mappedProject) {
            mappedProject.objectList = mappedObjectList
        } else {
            return nil
        }

        if let mappedVariables = CBXMLMapping.mapVariables(project: project, mappedProject: &mappedProject) {
            mappedProject.variables = mappedVariables
        } else {
            return nil
        }

        return mappedProject
    }
}

extension CBXMLMapping {

    // MARK: - mapObjectList
    static func mapObjectList(project: CBProject?, currentProject: inout Project) -> NSMutableArray? {
        guard let project = project else { return nil }
        guard let objectList = project.scenes?.first?.objectList?.object else { return nil }

        // TODO: NOW ONLY WORKING WITH ONE SCENE!!!
        var resultObjectList = [SpriteObject]()
        for object in objectList {
            if let mappedObject = mapObject(object: object) {
                mappedObject.project = currentProject
                resultObjectList.append(mappedObject)
            }
        }
        if resultObjectList.isEmpty { return nil }

        return NSMutableArray(array: resultObjectList)
    }

    static func mapObject(object: CBObject?) -> SpriteObject? {
        guard let object = object else { return nil }
        guard let lookList = object.lookList else { return nil }
        var result = SpriteObject()

        result.name = object.name
        result.lookList = mapLookListToObject(input: lookList)
        //result.soundList = mapSoundListToObject(input: soundList, cbProject: cbProject, object: input)
        if let mappedScriptList = mapScriptList(scriptList: object.scriptList, currentObject: &result) {
            result.scriptList = mappedScriptList
        }

        return result
    }

    static func mapScriptList(scriptList: CBScriptList?, currentObject: inout SpriteObject) -> NSMutableArray? {
        guard let scriptList = scriptList?.script else { return nil }

        var resultScriptList = [Script]()
        for script in scriptList {
            if let scr = mapScript(script: script) {
                scr.object = currentObject
                resultScriptList.append(scr)
            }
        }
        if resultScriptList.isEmpty { return nil }

        return NSMutableArray(array: resultScriptList)
    }

    static func mapScript(script: CBScript?) -> Script? {
        guard let script = script else { return nil }

        // TODO: IMPLEMENT OTHER SCRIPT TYPES!!!
        var result = StartScript()
        if let brickList = mapBrickList(brickList: script.brickList, currentScript: &result) {
            result.brickList = brickList
        }
        if result.brickList == nil { return nil }

        // TODO: IMPLEMENT isUserScript

        return result
    }

    static func mapBrickList(brickList: CBBrickList?, currentScript: inout StartScript) -> NSMutableArray? {
        guard let brickList = brickList?.brick else { return nil }

        var resultBrickList = [Brick]()
        for brick in brickList {
            switch brick.type?.uppercased() {

            case kSetVariableBrick.uppercased():
                let newBrick = SetVariableBrick()
                newBrick.userVariable = resolveUserVariable(brick: brick, currentBrickList: &resultBrickList)
                newBrick.uVar = newBrick.userVariable
                newBrick.variableFormula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kChangeVariableBrick.uppercased():
                let newBrick = ChangeVariableBrick()
                newBrick.userVariable = resolveUserVariable(brick: brick, currentBrickList: &resultBrickList)
                newBrick.uVar = newBrick.userVariable
                newBrick.variableFormula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kShowTextBrick.uppercased():
                let newBrick = ShowTextBrick()
                newBrick.userVariable = resolveUserVariable(brick: brick, currentBrickList: &resultBrickList)
                newBrick.uVar = newBrick.userVariable
                newBrick.xFormula = mapFormulaListToBrick(input: brick)?.lastObject as? Formula
                newBrick.yFormula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula

//                newBrick.userVariable.textLabel = SKLabelNode(fontNamed: kSceneDefaultFont)
//                newBrick.userVariable.textLabel.text = ""
//                newBrick.userVariable.textLabel.zPosition = CGFloat(LayerSensor.defaultRawValue + 1)
//                newBrick.userVariable.textLabel.fontColor = UIColor.black
//                newBrick.userVariable.textLabel.fontSize = CGFloat(kSceneLabelFontSize)
//                newBrick.userVariable.textLabel.isHidden = true
//                newBrick.userVariable.textLabel.horizontalAlignmentMode = .left


                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kHideTextBrick.uppercased():
                let newBrick = HideTextBrick()
                newBrick.userVariable = resolveUserVariable(brick: brick, currentBrickList: &resultBrickList)
                newBrick.uVar = newBrick.userVariable
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kAddItemToUserListBrick.uppercased():
                let newBrick = AddItemToUserListBrick()
                newBrick.userList = resolveUserVariable(brick: brick, currentBrickList: &resultBrickList)
                newBrick.uVar = newBrick.userList
                newBrick.listFormula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kDeleteItemOfUserListBrick.uppercased():
                let newBrick = DeleteItemOfUserListBrick()
                newBrick.userList = resolveUserVariable(brick: brick, currentBrickList: &resultBrickList)
                newBrick.uVar = newBrick.userList
                newBrick.listFormula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kInsertItemIntoUserListBrick.uppercased():
                let newBrick = InsertItemIntoUserListBrick()
                newBrick.userList = resolveUserVariable(brick: brick, currentBrickList: &resultBrickList)
                newBrick.uVar = newBrick.userList
                newBrick.index = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.elementFormula = mapFormulaListToBrick(input: brick)?.lastObject as? Formula
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kReplaceItemInUserListBrick.uppercased():
                let newBrick = ReplaceItemInUserListBrick()
                newBrick.userList = resolveUserVariable(brick: brick, currentBrickList: &resultBrickList)
                newBrick.uVar = newBrick.userList
                newBrick.elementFormula = mapFormulaListToBrick(input: brick)?.lastObject as? Formula
                newBrick.index = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            default:
                print("UNSUPPORTED BRICK!!!")
            }
        }
        if resultBrickList.isEmpty { return nil }

        return NSMutableArray(array: resultBrickList)
    }

    static func resolveUserVariable(brick: CBBrick?, currentBrickList: inout [Brick]) -> UserVariable? {
        guard let brick = brick else { return nil }

        if let variable = brick.userVariable {
            return allocUserVariable(name: variable, isList: false)
        } else if let variable = brick.userList {
            return allocUserVariable(name: variable, isList: true)
        } else if let reference = brick.userVariableReference {
            var splittedReference = reference.split(separator: "/")
            splittedReference.forEach { if $0 == ".." { splittedReference.removeObject($0) } }
            if splittedReference.count == 2, let string = splittedReference.first {
                let index = extractNumberInBacesFrom(string: String(string))
                if index < currentBrickList.count {
                    return currentBrickList[index].uVar
                }
            }
        }

        return nil
    }

    static func allocUserVariable(name: String, isList: Bool) -> UserVariable {
        let userVar = UserVariable()
        userVar.name = name
        userVar.isList = isList ? true : false
        return userVar
    }

    // MARK: - mapVariables
    static func mapVariables(project: CBProject?, mappedProject: inout Project) -> VariablesContainer? {
        let container = VariablesContainer()

        container.programListOfLists = mapProgramListOfLists(project: project, mappedProject: &mappedProject)
        if container.programListOfLists == nil { return nil }

        container.programVariableList = mapProgramVariableList(project: project, mappedProject: &mappedProject)
        if container.programVariableList == nil { return nil }

        container.objectListOfLists = mapObjectListOfLists(project: project, mappedProject: &mappedProject)
        if container.objectListOfLists == nil { return nil }

        container.objectVariableList = mapObjectVariableList(project: project, mappedProject: &mappedProject)
        if container.objectVariableList == nil { return nil }

        return container
    }

    // MARK: - mapProgramListOfLists
    static func mapProgramListOfLists(project: CBProject?, mappedProject: inout Project) -> NSMutableArray? {
        guard let programListOfLists = project?.programListOfLists?.list else { return nil }
        var result = [UserVariable]()

        // TODO: eventually value???
        for variable in programListOfLists {
            let referencedUserVariable = resolveUserVariableReference(reference: variable.reference, mappedProject: &mappedProject)
            if let uVar = referencedUserVariable {
                result.append(uVar.pointee)
            }
        }

        return NSMutableArray(array: result)
    }

    // MARK: - mapProgramVariableList
    static func mapProgramVariableList(project: CBProject?, mappedProject: inout Project) -> NSMutableArray? {
        guard let programVariableList = project?.programVariableList?.userVariable else { return nil }
        var result = [UserVariable]()

        // TODO: eventually value???
        for variable in programVariableList {
            let referencedUserVariable = resolveUserVariableReference(reference: variable.reference, mappedProject: &mappedProject)
            if let uVar = referencedUserVariable {
                result.append(uVar.pointee)
            }
        }

        return NSMutableArray(array: result)
    }

    // MARK: - mapObjectListOfLists
    static func mapObjectListOfLists(project: CBProject?, mappedProject: inout Project) -> OrderedMapTable? {
        guard let scenes = project?.scenes else { return nil }
        let result = OrderedMapTable.weakToStrongObjectsMapTable() as! OrderedMapTable

        for scene in scenes {
            if let objectListOfList = scene.data?.objectListOfList?.entry {
                for entry in objectListOfList {
                    if let lists = entry.list {

                        let referencedObject = resolveObjectReference(reference: entry.object, mappedProject: &mappedProject)?.pointee

                        var referencedList = [UserVariable]()
                        for list in lists {
                            if let element = resolveUserVariableReference(reference: list.userList, mappedProject: &mappedProject) {
                                referencedList.append(element.pointee)
                            }
                        }

                        if referencedList.isEmpty == false {
                            result.setObject(NSArray(array: referencedList), forKey: referencedObject)
                        }
                    }
                }
            }
        }

        return result
    }

    // MARK: - mapObjectListOfLists
    static func mapObjectVariableList(project: CBProject?, mappedProject: inout Project) -> OrderedMapTable? {
        guard let scenes = project?.scenes else { return nil }
        let result = OrderedMapTable.weakToStrongObjectsMapTable() as! OrderedMapTable

        for scene in scenes {
            if let objectVariableList = scene.data?.objectVariableList?.entry {
                for entry in objectVariableList {
                    if let lists = entry.list {

                        let referencedObject = resolveObjectReference(reference: entry.object, mappedProject: &mappedProject)?.pointee

                        var referencedList = [UserVariable]()
                        for list in lists {
                            if let element = resolveUserVariableReference(reference: list.userVariable, mappedProject: &mappedProject) {
                                referencedList.append(element.pointee)
                            }
                        }

                        if referencedList.isEmpty == false {
                            result.setObject(NSArray(array: referencedList), forKey: referencedObject)
                        }
                    }
                }
            }
        }

        return result
    }

    static func resolveObjectReference(reference: String?, mappedProject: inout Project) -> UnsafeMutablePointer<SpriteObject>? {
        let resolvedReferenceString = resolveReferenceString(reference: reference)
        guard let resolvedString = resolvedReferenceString else { return nil }

        if let oNr = resolvedString.0, oNr < mappedProject.objectList.count {
            if let obj = mappedProject.objectList[oNr] as? SpriteObject {
                let object = UnsafeMutablePointer<SpriteObject>.allocate(capacity: 1)
                object.initialize(to: obj)
                return object
            }
        }

        return nil
    }

    static func resolveUserVariableReference(reference: String?, mappedProject: inout Project) -> UnsafeMutablePointer<UserVariable>? {
        let resolvedReferenceString = resolveReferenceString(reference: reference)
        guard let resolvedString = resolvedReferenceString else { return nil }

        if let oNr = resolvedString.0, let sNr = resolvedString.1, let bNr = resolvedString.2, oNr < mappedProject.objectList.count {
            if let obj = mappedProject.objectList[oNr] as? SpriteObject {
                if let scr = obj.scriptList[sNr] as? Script, sNr < obj.scriptList.count {
                    if let br = scr.brickList[bNr] as? Brick, bNr < scr.brickList.count {
                        let uVarPtr = UnsafeMutablePointer<UserVariable>.allocate(capacity: 1)
                        uVarPtr.initialize(to: br.uVar)
                        return uVarPtr
                    }
                }
            }
        }
        // TODO: implement other two cases!!!

        return nil
    }

    // MARK: - resolveReferenceString
    static func resolveReferenceString(reference: String?) -> (Int?, Int?, Int?)? {
        guard let reference = reference else { return nil }
        var splittedReference = reference.split(separator: "/")
        splittedReference.forEach { if $0 == ".." { splittedReference.removeObject($0) } }
        var counter = 0
        var objectNr: Int?
        var scriptNr: Int?
        var brickNr: Int?

        if splittedReference.count == 2, let objString = splittedReference.last {
            objectNr = extractNumberInBacesFrom(string: String(objString))
        } else {
            for reference in splittedReference.reversed() {
                counter += 1
                if counter == 2 {
                    brickNr = extractNumberInBacesFrom(string: String(reference))
                }
                if counter == 4 {
                    scriptNr = extractNumberInBacesFrom(string: String(reference))
                }
                if counter == 6 {
                    objectNr = extractNumberInBacesFrom(string: String(reference))
                }
            }
        }

        return (objectNr, scriptNr, brickNr)
    }

    static func extractNumberInBacesFrom(string: String) -> Int {
        var firstDigit: Int?
        var secondDigit: Int?
        var thirdDigit: Int?

        let firstDigitRange = string.range(of: "[(0-9)*]", options: .regularExpression)

        if let fdr = firstDigitRange {
            firstDigit = Int(string[fdr])

            let secondPartOfString = string[Range(uncheckedBounds: (lower: fdr.upperBound, upper: string.endIndex))]
            let secondDigitRange = secondPartOfString.range(of: "[(0-9)*]", options: .regularExpression)

            if let sdr = secondDigitRange {
                secondDigit = Int(string[sdr])

                let thirdPartOfString = string[Range(uncheckedBounds: (lower: sdr.upperBound, upper: string.endIndex))]
                let thirdDigitRange = thirdPartOfString.range(of: "[(0-9)*]", options: .regularExpression)

                if let tdr = thirdDigitRange {
                    thirdDigit = Int(string[tdr])
                }
            }
        }

        if let first = firstDigit, let second = secondDigit, let third = thirdDigit {
            return first * 100 + second * 10 + third - 1
        } else if let first = firstDigit, let second = secondDigit {
            return first * 10 + second - 1
        } else if let first = firstDigit {
            return first - 1
        } else {
            return 0
        }
    }
}

enum CBXMLError: Error {
    case lookListMapError
    case soundListMapError
    case scriptListMapError

    case unsupportedScript
    case brickMappingError
    case unsupportedBrick

    case unknownError
}
