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

        let kBroadcastBrick: String = "BroadcastBrick"
        let kBroadcastWaitBrick: String = "BroadcastWaitBrick"
        let kForeverBrick: String = "ForeverBrick"
        let kIfLogicBeginBrick: String = "IfLogicBeginBrick"
        let kIfLogicElseBrick: String = "IfLogicElseBrick"
        let kIfLogicEndBrick: String = "IfLogicEndBrick"
        let kIfThenLogicBeginBrick: String = "IfThenLogicBeginBrick"
        let kIfThenLogicEndBrick: String = "IfThenLogicEndBrick"
        let kLoopEndBrick: String = "LoopEndBrick"
        let kLoopEndlessBrick: String = "LoopEndlessBrick"
        let kNoteBrick: String = "NoteBrick"
        let kRepeatBrick: String = "RepeatBrick"
        let kRepeatUntilBrick: String = "RepeatUntilBrick"
        let kWaitBrick: String = "WaitBrick"
        let kWaitUntilBrick: String = "WaitUntilBrick"

        let kPlaceAtBrick: String = "PlaceAtBrick"
        let kChangeXByNBrick: String = "ChangeXByNBrick"
        let kChangeYByNBrick: String = "ChangeYByNBrick"
        let kSetXBrick: String = "SetXBrick"
        let kSetYBrick: String = "SetYBrick"
        let kIfOnEdgeBounceBrick: String = "IfOnEdgeBounceBrick"
        let kMoveNStepsBrick: String = "MoveNStepsBrick"
        let kTurnLeftBrick: String = "TurnLeftBrick"
        let kTurnRightBrick: String = "TurnRightBrick"
        let kPointInDirectionBrick: String = "PointInDirectionBrick"
        let kPointToBrick: String = "PointToBrick"
        let kGlideToBrick: String = "GlideToBrick"
        let kVibrationBrick: String = "VibrationBrick"

        let kSetBackgroundBrick: String = "SetBackgroundBrick"
        let kSetLookBrick: String = "SetLookBrick"
        let kNextLookBrick: String = "NextLookBrick"
        let kPreviousLookBrick: String = "PreviousLookBrick"
        let kSetSizeToBrick: String = "SetSizeToBrick"
        let kChangeSizeByNBrick: String = "ChangeSizeByNBrick"
        let kHideBrick: String = "HideBrick"
        let kShowBrick: String = "ShowBrick"
        let kSetTransparencyBrick: String = "SetTransparencyBrick"
        let kChangeTransparencyByNBrick: String = "ChangeTransparencyByNBrick"
        let kSetBrightnessBrick: String = "SetBrightnessBrick"
        let kChangeBrightnessByNBrick: String = "ChangeBrightnessByNBrick"
        let kSetColorBrick: String = "SetColorBrick"
        let kChangeColorByNBrick: String = "ChangeColorByNBrick"
        let kClearGraphicEffectBrick: String = "ClearGraphicEffectBrick"
        let kFlashBrick: String = "FlashBrick"
        let kCameraBrick: String = "CameraBrick"
        let kChooseCameraBrick: String = "ChooseCameraBrick"

        let kPlaySoundBrick: String = "PlaySoundBrick"
        let kStopAllSoundsBrick: String = "StopAllSoundsBrick"
        let kSetVolumeToBrick: String = "SetVolumeToBrick"
        let kChangeVolumeByNBrick: String = "ChangeVolumeByNBrick"
        let kSpeakBrick: String = "SpeakBrick"
        let kSpeakAndWaitBrick: String = "SpeakAndWaitBrick"

        let kSetVariableBrick: String = "SetVariableBrick"
        let kChangeVariableBrick: String = "ChangeVariableBrick"
        let kShowTextBrick: String = "ShowTextBrick"
        let kHideTextBrick: String = "HideTextBrick"
        let kAddItemToUserListBrick: String = "AddItemToUserListBrick"
        let kDeleteItemOfUserListBrick: String = "DeleteItemOfUserListBrick"
        let kInsertItemIntoUserListBrick: String = "InsertItemIntoUserListBrick"
        let kReplaceItemInUserListBrick: String = "ReplaceItemInUserListBrick"

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

    // MARK: - mapLookListToObject
    static func mapLookListToObject(input: CBLookList?) -> NSMutableArray {
        var lookList = [Look]()
        guard let input = input?.look else { return  NSMutableArray(array: lookList) }

        for look in input {
            let object = Look()

            object.name = look.name
            object.fileName = look.fileName

            lookList.append(object)
        }

        return NSMutableArray(array: lookList)
    }

    // MARK: - mapSoundListToObject
    static func mapSoundListToObject(input: CBSoundList?, cbProject: CBProject?, object: CBObject) -> NSMutableArray {
        var soundList = [Sound]()
        guard let input = input?.sound else { return  NSMutableArray(array: soundList) }

        for sound in input {
            if let ref = sound.reference {
                var brick: CBBrick?
                if ref.split(separator: "/").count < 9 {
                    let extr = extractAbstractNumbersFrom(object: object, reference: ref, project: cbProject)
                    if let sl = object.scriptList?.script, sl.count > extr.0, let bl = sl[extr.0].brickList?.brick, bl.count > extr.1 {
                        brick = bl[extr.1]
                    }
                } else {
                    let extr = extractAbstractNumbersFrom(reference: ref, project: cbProject)
                    if let ol = cbProject?.scenes?.first?.objectList?.object, ol.count > extr.0 {
                        if let sl = ol[extr.0].scriptList?.script, sl.count > extr.1, let bl = sl[extr.1].brickList?.brick, bl.count > extr.2 {
                            brick = bl[extr.2]
                        }
                    }
                }
                if let brick = brick, let name = brick.sound?.name, let filename = brick.sound?.fileName {
                    let soundToAppend = Sound(name: name, fileName: filename)
                    if soundList.contains(soundToAppend) == false {
                        soundList.append(soundToAppend)
                    }
                }
            } else if let name = sound.name, let filename = sound.fileName {
                let soundToAppend = Sound(name: name, fileName: filename)
                if soundList.contains(soundToAppend) == false {
                    soundList.append(soundToAppend)
                }
            }
        }

        return NSMutableArray(array: soundList)
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
