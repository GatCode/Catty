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

extension CBXMLMapping {

    // MARK: - mapObjectList
    static func mapObjectList(project: CBProject?, currentProject: inout Project) -> NSMutableArray? {
        guard let project = project else { return nil }
        guard let objectList = project.scenes?.first?.objectList?.object else { return nil } // TODO: NOW ONLY WORKING WITH ONE SCENE!!!

        var resultObjectList = [SpriteObject]()
        for object in objectList {
            if let mappedObject = mapObject(object: object, project: project) {
                mappedObject.project = currentProject
                resultObjectList.append(mappedObject)
            }
        }
        if resultObjectList.isEmpty { return nil }

        return NSMutableArray(array: resultObjectList)
    }

    static func mapObject(object: CBObject?, project: CBProject?) -> SpriteObject? {
        guard let object = object else { return nil }
        guard let project = project else { return nil }
        guard let lookList = object.lookList else { return nil }
        guard let soundList = object.soundList else { return nil }

        var result = SpriteObject()
        result.name = object.name
        result.lookList = mapLookList(lookList: lookList)
        result.soundList = mapSoundList(soundList: soundList, project: project, object: object)
        result.scriptList = mapScriptList(scriptList: object.scriptList, currentObject: &result)
        if result.lookList == nil || result.soundList == nil || result.scriptList == nil { return nil }

        return result
    }

    // MARK: - mapLookList
    static func mapLookList(lookList: CBLookList?) -> NSMutableArray? {
        guard let input = lookList?.look else { return  nil }

        var lookList = [Look]()
        for look in input {
            if let newLook = allocLook(name: look.name, filename: look.fileName) {
                lookList.append(newLook)
            }
        }

        return NSMutableArray(array: lookList)
    }

    static func allocLook(name: String?, filename: String?) -> Look? {
        guard let name = name else { return nil }
        guard let filename = filename else { return nil }

        let newLook = Look()
        newLook.name = name
        newLook.fileName = filename

        for look in mappingLookList where look.name == newLook.name {
            return look
        }

        mappingLookList.append(newLook)
        return newLook
    }

    // MARK: - mapSoundList
    static func mapSoundList(soundList: CBSoundList?, project: CBProject?, object: CBObject?) -> NSMutableArray? {
        guard let input = soundList?.sound else { return nil }
        guard let project = project else { return nil }

        var soundList = [Sound]()
        for sound in input {

            if let resolvedSound = resolveSoundReference(reference: sound.reference, project: project, object: object), soundList.contains(resolvedSound) == false {
                soundList.append(resolvedSound)
            }

            if let newSound = allocSound(name: sound.name, filename: sound.fileName), soundList.contains(newSound) == false {
                soundList.append(newSound)
            }
        }

        return NSMutableArray(array: soundList)
    }

    static func resolveSoundReference(reference: String?, project: CBProject?, object: CBObject?) -> Sound? {
        let resolvedReferenceString = resolveReferenceStringShort(reference: reference, project: project, object: object)
        guard let resolvedString = resolvedReferenceString else { return nil }

        var soundNameToResolve: String?
        var soundFileNameToResolve: String?
        let sIdx = resolvedString.0 ?? 0
        let bIdx = resolvedString.1 ?? 0

        if let scriptList = object?.scriptList?.script, sIdx < scriptList.count {
            if let brickList = scriptList[sIdx].brickList?.brick, bIdx < brickList.count {
                soundNameToResolve = brickList[bIdx].sound?.name
                soundFileNameToResolve = brickList[bIdx].sound?.fileName
            }
        }

        return allocSound(name: soundNameToResolve, filename: soundFileNameToResolve)
    }

    static func allocSound(name: String?, filename: String?) -> Sound? {
        guard let name = name else { return nil }
        guard let filename = filename else { return nil }

        let newSound = Sound(name: name, fileName: filename)

        for sound in mappingSoundList where sound.name == newSound.name {
            return sound
        }

        mappingSoundList.append(newSound)
        return newSound
    }

    // MARK: - mapScriptList
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

        var result: Script?
        switch script.type?.uppercased() {
        case kStartScript.uppercased():
            let scr = StartScript()
            result = scr
        case kWhenScript.uppercased():
            let scr = WhenScript()
            if let action = script.action {
                scr.action = action
            }
            result = scr
        case kWhenTouchDownScript.uppercased():
            let scr = WhenTouchDownScript()
            result = scr
        case kBroadcastScript.uppercased():
            let scr = BroadcastScript()
            if let msg = script.receivedMessage {
                scr.receivedMessage = msg
            }
            result = scr
        default:
            if script.type?.hasSuffix(kScript) ?? false {
                let scr = BroadcastScript()
                if let type = script.type {
                    let msg = String(format: "%@ %@", "timeNow in hex: ", kLocalizedUnsupportedScript, type)
                    scr.receivedMessage = msg
                }
                result = scr
            }
        }

        if let res = result {
            res.brickList = mapBrickList(brickList: script.brickList, currentScript: &result) // TODO: IMPLEMENT isUserScript
            return res.brickList != nil ? result : nil
        }

        return nil
    }

    // MARK: - mapBrickList
    static func mapBrickList(brickList: CBBrickList?, currentScript: inout Script?) -> NSMutableArray? {
        guard let brickList = brickList?.brick else { return nil }
        guard let currentScript = currentScript else { return nil }

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

        if let reference = brick.userVariableReference {
            var splittedReference = reference.split(separator: "/")
            splittedReference.forEach { if $0 == ".." { splittedReference.removeObject($0) } }
            if splittedReference.count == 2, let string = splittedReference.first {
                let index = extractNumberInBacesFrom(string: String(string))
                if index < currentBrickList.count {
                    return currentBrickList[index].uVar
                }
            }
        } else if let variable = brick.userVariable {
            return allocUserVariable(name: variable, isList: false)
        } else if let variable = brick.userList {
            return allocUserVariable(name: variable, isList: true)
        }

        return nil
    }

    static func allocUserVariable(name: String, isList: Bool) -> UserVariable {
        let userVar = UserVariable()
        userVar.name = name
        userVar.isList = isList ? true : false
        return userVar
    }

    // MARK: - mapFormula
    static func mapFormulaListToBrick(input: CBBrick?) -> NSMutableArray? {
        var formulaList = [Formula]()

        if let formulas = input?.formulaList?.formula {
            for formula in formulas {
                let mappedFormula = mapCBFormulaToFormula(input: formula)
                if formulaList.contains(mappedFormula) == false {
                    formulaList.append(mappedFormula)
                }
            }
        } else if let formulas = input?.formulaTree?.formula {
            for formula in formulas {
                let mappedFormula = mapCBFormulaToFormula(input: formula)
                if formulaList.contains(mappedFormula) == false {
                    formulaList.append(mappedFormula)
                }
            }
        } else {
            return nil
        }

        return NSMutableArray(array: formulaList)
    }

    static func mapCBFormulaToFormula(input: CBFormula?) -> Formula {
        let formula = Formula()
        guard let input = input else { return formula }

        var elementType = ElementType.NUMBER
        switch input.type {
        case "NUMBER":
            elementType = ElementType.NUMBER
        case "OPERATOR":
            elementType = ElementType.OPERATOR
        case "USER_VARIABLE":
            elementType = ElementType.USER_VARIABLE
        case "USER_LIST":
            elementType = ElementType.USER_LIST
        case "FUNCTION":
            elementType = ElementType.FUNCTION
        case "SENSOR":
            elementType = ElementType.SENSOR
        case "BRACKET":
            elementType = ElementType.BRACKET
        default:
            elementType = ElementType.STRING
        }

        let formulaTree = FormulaElement(elementType: elementType, value: input.value, leftChild: nil, rightChild: nil, parent: nil)

        if let leftChild = input.leftChild, let tree = formulaTree {
            formulaTree?.leftChild = mapCBLRChildToFormulaTree(input: leftChild, tree: tree)
        }

        if let rightChild = input.rightChild, let tree = formulaTree {
            formulaTree?.rightChild = mapCBLRChildToFormulaTree(input: rightChild, tree: tree)
        }

        formula.formulaTree = formulaTree
        return formula
    }

    static func mapCBLRChildToFormulaTree(input: CBLRChild?, tree: FormulaElement) -> FormulaElement? {
        guard let input = input else { return nil }
        let child = FormulaElement(type: input.type, value: input.value, leftChild: nil, rightChild: nil, parent: nil)

        if let leftChild = input.leftChild.first, leftChild != nil, let ch = child {
            let leftChild = mapCBLRChildToFormulaTree(input: leftChild, tree: ch)
            child?.parent = tree
            child?.leftChild = leftChild
        }

        if let rightChild = input.rightChild.first, rightChild != nil, let ch = child {
            let rightChild = mapCBLRChildToFormulaTree(input: rightChild, tree: ch)
            child?.parent = tree
            child?.rightChild = rightChild
        }

        return child
    }

    static func extractAbstractNumbersFrom(object: CBObject, reference: String, project: CBProject?) -> (Int, Int) {
        let splittedReference = reference.split(separator: "/")
        var brickNr = 0
        var scriptNr = 0
        var brickType = ""
        var scriptType = ""

        var fallbackCounter = 0
        for string in splittedReference.reversed() {
            let name = string.split(separator: "[")
            fallbackCounter += 1
            if fallbackCounter == 2 {
                if let n = name.first, n != "brick" {
                    brickType = String(n.replacingOccurrences(of: ".", with: ""))
                }
                brickNr = extractNumberInBacesFrom(string: String(string))
            }
            if fallbackCounter == 4 {
                if let n = name.first, n != "script" {
                    scriptType = String(n.replacingOccurrences(of: ".", with: ""))
                }
                scriptNr = extractNumberInBacesFrom(string: String(string))
            }
        }

        if scriptType.isEmpty == false {
            var abstractScriptNr = 0
            if let scriptList = object.scriptList?.script {
                for script in scriptList {
                    if script.type == scriptType {
                        scriptNr -= 1
                    }
                    if scriptNr < 0 {
                        break
                    }
                    abstractScriptNr += 1
                }
                scriptNr = abstractScriptNr
            }
        }

        if brickType.isEmpty == false {
            var abstractBrickNr = 0
            if let brickList = object.scriptList?.script?[scriptNr].brickList?.brick {
                for brick in brickList {
                    if brick.type == brickType {
                        brickNr -= 1
                    }
                    if brickNr < 0 {
                        break
                    }
                    abstractBrickNr += 1
                }
                brickNr = abstractBrickNr
            }
        }

        return (scriptNr, brickNr)
    }

    static func extractAbstractNumbersFrom(reference: String, project: CBProject?) -> (Int, Int, Int) {
        guard let project = project else { return (0, 0, 0) }
        let splittedReference = reference.split(separator: "/")
        var brickNr = 0
        var scriptNr = 0
        var objectNr = 0
        var brickType = ""
        var scriptType = ""

        var fallbackCounter = 0
        for string in splittedReference.reversed() {
            let name = string.split(separator: "[")
            fallbackCounter += 1
            if fallbackCounter == 2 {
                if let n = name.first, n != "brick" {
                    brickType = String(n.replacingOccurrences(of: ".", with: ""))
                }
                brickNr = extractNumberInBacesFrom(string: String(string))
            }
            if fallbackCounter == 4 {
                if let n = name.first, n != "script" {
                    scriptType = String(n.replacingOccurrences(of: ".", with: ""))
                }
                scriptNr = extractNumberInBacesFrom(string: String(string))
            }
            if fallbackCounter == 6 {
                objectNr = extractNumberInBacesFrom(string: String(string))
            }
        }

        if scriptType != "" && brickType != "", let objectList = project.scenes?.first?.objectList?.object?[objectNr] {

            var abstractScriptNr = 0
            if let scriptList = objectList.scriptList?.script {
                for script in scriptList {
                    if script.type == scriptType {
                        scriptNr -= 1
                    }
                    if scriptNr < 0 {
                        break
                    }
                    abstractScriptNr += 1
                }
                scriptNr = abstractScriptNr
            }

            var abstractBrickNr = 0
            if let brickList = objectList.scriptList?.script?[scriptNr].brickList?.brick {
                for brick in brickList {
                    if brick.type == brickType {
                        brickNr -= 1
                    }
                    if brickNr < 0 {
                        break
                    }
                    abstractBrickNr += 1
                }
                brickNr = abstractBrickNr
            }
        }

        return (objectNr, scriptNr, brickNr)
    }
}
