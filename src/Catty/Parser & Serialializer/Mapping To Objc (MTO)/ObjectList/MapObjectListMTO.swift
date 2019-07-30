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

// swiftlint:disable large_tuple

extension CBXMLMappingToObjc {

    // MARK: - mapObjectList
    static func mapObjectList(project: CBProject?, currentProject: inout Project) -> NSMutableArray? {
        guard let project = project else { return nil }
        guard let objectList = project.scenes?.first?.objectList?.objects else { return nil }

        var resultObjectList = [SpriteObject]()
        for object in objectList {
            mappingVariableListLocal.removeAll()

            if let ref = object.reference {
                let resolvedString = resolveReferenceString(reference: ref, project: project)
                if let resolvedString = resolvedString, let oNr = resolvedString.0, oNr < resultObjectList.count {
                    if let sNr = resolvedString.1, sNr < resultObjectList[oNr].scriptList.count, let script = resultObjectList[oNr].scriptList[sNr] as? Script {
                        if let bNr = resolvedString.2, bNr < script.brickList.count, let brick = script.brickList[bNr] as? Brick {
                            if let brick = brick as? PointToBrick, brick.pointedObject != nil {
                                resultObjectList.append(brick.pointedObject)
                            }
                        }
                    }
                }
            } else if let mappedObject = mapObject(object: object, objectList: objectList, project: project) {
                mappedObject.project = currentProject
                resultObjectList.append(mappedObject)
            }
        }

        return NSMutableArray(array: resultObjectList)
    }

    static func mapObject(object: CBObject?, objectList: [CBObject]?, project: CBProject?) -> SpriteObject? {
        var result = SpriteObject()
        guard let object = object else { return nil }
        guard let project = project else { return nil }
        guard let lookList = object.lookList else { return nil }
        guard let soundList = object.soundList else { return nil }

        if let alreadyMapped = CBXMLMappingToObjc.spriteObjectList.first(where: { $0.name == object.name }) {
            return alreadyMapped
        }

        result.name = object.name
        result.lookList = mapLookList(lookList: lookList)
        result.soundList = mapSoundList(soundList: soundList, project: project, object: object)
        result.scriptList = mapScriptList(object: object, objectList: objectList, project: project, currentObject: &result)

        CBXMLMappingToObjc.spriteObjectList.append(result)

        return result
    }

    // MARK: - mapLookList
    static func mapLookList(lookList: CBLookList?) -> NSMutableArray? {
        guard let input = lookList?.looks else { return  nil }

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

        return newLook
    }

    // MARK: - mapSoundList
    static func mapSoundList(soundList: CBSoundList?, project: CBProject?, object: CBObject?) -> NSMutableArray? {
        guard let input = soundList?.sounds else { return nil }
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

        if let scriptList = object?.scriptList?.scripts, sIdx < scriptList.count {
            if let brickList = scriptList[sIdx].brickList?.bricks, bIdx < brickList.count {
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

        for sound in mappingSoundList where sound.fileName == newSound.fileName {
            return sound
        }

        mappingSoundList.append(newSound)
        return newSound
    }

    // MARK: - mapScriptList
    static func mapScriptList(object: CBObject?, objectList: [CBObject]?, project: CBProject?, currentObject: inout SpriteObject) -> NSMutableArray? {
        guard let scriptList = object?.scriptList?.scripts else { return nil }

        var resultScriptList = [Script]()
        for script in scriptList {
            if let scr = mapScript(script: script, objectList: objectList, object: object, project: project, currentObject: &currentObject) {
                scr.object = currentObject
                resultScriptList.append(scr)
            }
        }

        return NSMutableArray(array: resultScriptList)
    }

    static func mapScript(script: CBScript?, objectList: [CBObject]?, object: CBObject?, project: CBProject?, currentObject: inout SpriteObject) -> Script? {
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
                scr.receivedMsg = msg
            }
            result = scr
        default:
            if script.type?.hasSuffix(kScript) ?? false {
                let scr = BroadcastScript()
                scr.receivedMessage = String(format: "%@ %@", kLocalizedUnsupportedScript, script.type ?? "")
                scr.receivedMsg = scr.receivedMessage
                result = scr
                unsupportedElements.append(script.type ?? "")
            }
        }

        if let res = result {
            res.isUserScript = script.isUserScript
            res.action = script.action
            res.brickList = mapBrickList(script: script, objectList: objectList, object: object, project: project, currScript: &result, currObject: &currentObject)
            return res
        }

        return nil
    }

    // MARK: - mapBrickList
    static func mapBrickList(script: CBScript?, objectList: [CBObject]?, object: CBObject?, project: CBProject?, currScript: inout Script?, currObject: inout SpriteObject) -> NSMutableArray? {
        guard let brickList = script?.brickList?.bricks else { return nil }
        guard let lookList = currObject.lookList else { return nil }
        guard let currentScript = currScript else { return nil }
        guard let objectList = objectList else { return nil }

        var resultBrickList = [Brick]()
        for brick in brickList {
            switch brick.type?.uppercased() {
            // MARK: Condition Bricks
            case kBroadcastBrick.uppercased():
                let newBrick = BroadcastBrick()
                if let msg = brick.broadcastMessage {
                    newBrick.broadcastMessage = msg
                }
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kBroadcastWaitBrick.uppercased():
                let newBrick = BroadcastWaitBrick()
                if let msg = brick.broadcastMessage {
                    newBrick.broadcastMessage = msg
                }
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kIfLogicBeginBrick.uppercased():
                let newBrick = IfLogicBeginBrick()
                newBrick.ifCondition = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kIfLogicElseBrick.uppercased():
                let newBrick = IfLogicElseBrick()
                for item in resultBrickList.reversed() where item.brickType == kBrickType.ifBrick {
                    if let item = item as? IfLogicBeginBrick, item.ifElseBrick == nil {
                        newBrick.ifBeginBrick = item
                        item.ifElseBrick = newBrick
                        break
                    }
                }
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kIfLogicEndBrick.uppercased():
                let newBrick = IfLogicEndBrick()
                for item in resultBrickList.reversed() where item.brickType == kBrickType.ifElseBrick {
                    if let item = item as? IfLogicElseBrick, item.ifEndBrick == nil {
                        newBrick.ifBeginBrick = item.ifBeginBrick
                        newBrick.ifElseBrick = item
                        item.ifBeginBrick.ifEndBrick = newBrick
                        item.ifEndBrick = newBrick
                        break
                    }
                }
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kIfThenLogicBeginBrick.uppercased():
                let newBrick = IfThenLogicBeginBrick()
                newBrick.ifCondition = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kIfThenLogicEndBrick.uppercased():
                let newBrick = IfThenLogicEndBrick()
                for item in resultBrickList.reversed() where item.brickType == kBrickType.ifThenBrick {
                    if let item = item as? IfThenLogicBeginBrick, item.ifEndBrick == nil {
                        newBrick.ifBeginBrick = item
                        item.ifEndBrick = newBrick
                        break
                    }
                }
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kForeverBrick.uppercased():
                let newBrick = ForeverBrick()
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kRepeatBrick.uppercased():
                let newBrick = RepeatBrick()
                newBrick.timesToRepeat = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kRepeatUntilBrick.uppercased():
                let newBrick = RepeatUntilBrick()
                newBrick.repeatCondition = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kLoopEndBrick.uppercased(), kLoopEndlessBrick.uppercased():
                let newBrick = LoopEndBrick()
                for item in resultBrickList.reversed() {
                    if let item = item as? RepeatBrick, item.loopEndBrick == nil {
                        newBrick.loopBeginBrick = item
                        item.loopEndBrick = newBrick
                        break
                    }
                    if let item = item as? RepeatUntilBrick, item.loopEndBrick == nil {
                        newBrick.loopBeginBrick = item
                        item.loopEndBrick = newBrick
                        break
                    }
                    if let item = item as? ForeverBrick, item.loopEndBrick == nil {
                        newBrick.loopBeginBrick = item
                        item.loopEndBrick = newBrick
                        break
                    }
                }
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kNoteBrick.uppercased():
                let newBrick = NoteBrick()
                newBrick.note = brick.noteMessage
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kWaitBrick.uppercased():
                let newBrick = WaitBrick()
                if let time = mapFormulaListToBrick(input: brick)?.firstObject as? Formula {
                    newBrick.timeToWaitInSeconds = time
                }
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kWaitUntilBrick.uppercased():
                let newBrick = WaitUntilBrick()
                if let condition = mapFormulaListToBrick(input: brick)?.firstObject as? Formula {
                    newBrick.waitCondition = condition
                }
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            // MARK: Motion Bricks
            case kPlaceAtBrick.uppercased():
                let newBrick = PlaceAtBrick()
                if let x = brick.xPosition, let y = brick.yPosition {
                    newBrick.xPosition = mapCBFormulaToFormula(input: x)
                    newBrick.yPosition = mapCBFormulaToFormula(input: y)
                } else {
                    newBrick.xPosition = mapFormulaListToBrick(input: brick)?.lastObject as? Formula
                    newBrick.yPosition = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                }
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kChangeXByNBrick.uppercased():
                let newBrick = ChangeXByNBrick()
                newBrick.xMovement = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kChangeYByNBrick.uppercased():
                let newBrick = ChangeYByNBrick()
                newBrick.yMovement = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kSetXBrick.uppercased():
                let newBrick = SetXBrick()
                newBrick.xPosition = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kSetYBrick.uppercased():
                let newBrick = SetYBrick()
                newBrick.yPosition = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kIfOnEdgeBounceBrick.uppercased():
                let newBrick = IfOnEdgeBounceBrick()
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kMoveNStepsBrick.uppercased():
                let newBrick = MoveNStepsBrick()
                newBrick.steps = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kTurnLeftBrick.uppercased():
                let newBrick = TurnLeftBrick()
                newBrick.degrees = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kTurnRightBrick.uppercased():
                let newBrick = TurnRightBrick()
                newBrick.degrees = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kPointInDirectionBrick.uppercased():
                let newBrick = PointInDirectionBrick()
                newBrick.degrees = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kPointToBrick.uppercased():
                let newBrick = PointToBrick()
                for object in objectList where object.name == brick.pointedObjectReference {
                    newBrick.pointedObject = mapObject(object: object, objectList: objectList, project: project)
                }
                if newBrick.pointedObject == nil, let pointed = brick.pointedObject {
                    newBrick.pointedObject = mapObject(object: pointed, objectList: objectList, project: project)
                }
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kGlideToBrick.uppercased():
                let newBrick = GlideToBrick()
                let formulaTreeMapping = mapFormulaListToBrick(input: brick)
                var orderArr = [String]()
                guard let formulaMapping = formulaTreeMapping else { break }
                if let mapping = formulaMapping as? [Formula] {
                    for mappedFormula in mapping {
                        switch mappedFormula.category {
                        case "X_DESTINATION":
                            newBrick.xDestination = mappedFormula
                            orderArr.append("X")
                        case "Y_DESTINATION":
                            newBrick.yDestination = mappedFormula
                            orderArr.append("Y")
                        default:
                            newBrick.durationInSeconds = mappedFormula
                            orderArr.append("D")
                        }
                    }
                }
                if newBrick.xDestination == nil || newBrick.yDestination == nil {
                    let xyMapping = mapXYDestinationsToBrick(input: brick)
                    newBrick.xDestination = xyMapping?.firstObject as? Formula
                    newBrick.yDestination = xyMapping?.lastObject as? Formula
                    orderArr.append("X")
                    orderArr.append("Y")
                }
                newBrick.serializationOrder = orderArr
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kVibrationBrick.uppercased():
                let newBrick = VibrationBrick()
                newBrick.durationInSeconds = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            // MARK: Look Bricks
            case kSetBackgroundBrick.uppercased():
                let newBrick = SetBackgroundBrick()
                let tmpSpriteObj = SpriteObject()
                tmpSpriteObj.lookList = lookList
                newBrick.setDefaultValuesFor(tmpSpriteObj)
                if let range = brick.lookReference?.range(of: "[(0-9)*]", options: .regularExpression) {
                    let index = String(brick.lookReference?[range] ?? "")
                    if let index = Int(index), index <= lookList.count, index > 0 {
                        newBrick.look = lookList[index - 1] as? Look
                    }
                }
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kSetLookBrick.uppercased():
                let newBrick = SetLookBrick()
                let tmpSpriteObj = SpriteObject()
                tmpSpriteObj.lookList = lookList
                newBrick.setDefaultValuesFor(tmpSpriteObj)
                if let range = brick.lookReference?.range(of: "[(0-9)*]", options: .regularExpression) {
                    let index = String(brick.lookReference?[range] ?? "")
                    if let index = Int(index), index <= lookList.count, index > 0 {
                        newBrick.look = lookList[index - 1] as? Look
                    }
                }
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kNextLookBrick.uppercased():
                let newBrick = NextLookBrick()
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kPreviousLookBrick.uppercased():
                let newBrick = PreviousLookBrick()
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kSetSizeToBrick.uppercased():
                let newBrick = SetSizeToBrick()
                newBrick.size = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kChangeSizeByNBrick.uppercased():
                let newBrick = ChangeSizeByNBrick()
                newBrick.size = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kShowBrick.uppercased():
                let newBrick = ShowBrick()
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kHideBrick.uppercased():
                let newBrick = HideBrick()
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kSetTransparencyBrick.uppercased(), kSetGhostEffectBrick.uppercased():
                let newBrick = SetTransparencyBrick()
                newBrick.transparency = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kChangeTransparencyByNBrick.uppercased(), kChangeGhostEffectByNBrick.uppercased():
                let newBrick = ChangeTransparencyByNBrick()
                newBrick.changeTransparency = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kSetBrightnessBrick.uppercased():
                let newBrick = SetBrightnessBrick()
                newBrick.brightness = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kChangeBrightnessByNBrick.uppercased():
                let newBrick = ChangeBrightnessByNBrick()
                newBrick.changeBrightness = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kSetColorBrick.uppercased():
                let newBrick = SetColorBrick()
                newBrick.color = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kChangeColorByNBrick.uppercased():
                let newBrick = ChangeColorByNBrick()
                newBrick.changeColor = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kClearGraphicEffectBrick.uppercased():
                let newBrick = ClearGraphicEffectBrick()
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kFlashBrick.uppercased(), kLedOnBrick.uppercased(), kLedOffBrick.uppercased():
                var newBrick = FlashBrick()
                if let flashState = brick.spinnerSelectionID {
                    newBrick = FlashBrick(choice: Int32(flashState) ?? 0)
                }
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kCameraBrick.uppercased():
                var newBrick = CameraBrick()
                if let cameraState = brick.spinnerSelectionID {
                    newBrick = CameraBrick(choice: Int32(cameraState) ?? 0)
                }
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kChooseCameraBrick.uppercased():
                var newBrick = ChooseCameraBrick()
                if let cameraState = brick.spinnerSelectionID {
                    newBrick = ChooseCameraBrick(choice: Int32(cameraState) ?? 0)
                }
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kThinkBubbleBrick.uppercased():
                let newBrick = ThinkBubbleBrick()
                newBrick.formula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kThinkForBubbleBrick.uppercased():
                let newBrick = ThinkForBubbleBrick()
                newBrick.stringFormula = mapFormulaListToBrick(input: brick)?.lastObject as? Formula
                newBrick.intFormula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            // MARK: Sound Bricks
            case kPlaySoundBrick.uppercased():
                let newBrick = PlaySoundBrick()
                if let soundReference = brick.soundReference {
                    var splittedReference = soundReference.split(separator: "/")
                    splittedReference = splittedReference.filter { $0 != ".." }
                    if splittedReference.count == 2, let soundString = splittedReference.last {
                        let soundIndex = extractNumberInBacesFrom(string: String(soundString))
                        if let newSoundList = object?.soundList?.sounds, soundIndex < newSoundList.count {
                            for sound in mappingSoundList where sound.fileName == newSoundList[soundIndex].fileName {
                                newBrick.sound = sound
                            }
                        }
                    } else {
                        print("ERROR MAPPING PLAYSOUNDBRICK")
                    }
                } else {
                    for sound in mappingSoundList where sound.fileName == brick.sound?.fileName {
                        newBrick.sound = sound
                    }
                }
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kStopAllSoundsBrick.uppercased():
                let newBrick = StopAllSoundsBrick()
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kSetVolumeToBrick.uppercased():
                let newBrick = SetVolumeToBrick()
                newBrick.volume = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kChangeVolumeByNBrick.uppercased():
                let newBrick = ChangeVolumeByNBrick()
                newBrick.volume = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kSpeakBrick.uppercased():
                let newBrick = SpeakBrick()
                newBrick.formula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.text = brick.noteMessage
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kSpeakAndWaitBrick.uppercased():
                let newBrick = SpeakAndWaitBrick()
                newBrick.formula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.text = brick.noteMessage
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            // MARK: Variable Bricks
            case kSetVariableBrick.uppercased():
                let newBrick = SetVariableBrick()
                newBrick.userVariable = resolveUserVariable(project: project, object: object, script: script, brick: brick, isList: false)
                newBrick.uVar = newBrick.userVariable
                newBrick.variableFormula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kChangeVariableBrick.uppercased():
                let newBrick = ChangeVariableBrick()
                newBrick.userVariable = resolveUserVariable(project: project, object: object, script: script, brick: brick, isList: false)
                newBrick.uVar = newBrick.userVariable
                newBrick.variableFormula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kShowTextBrick.uppercased():
                let newBrick = ShowTextBrick()
                newBrick.userVariable = resolveUserVariable(project: project, object: object, script: script, brick: brick, isList: false)
                newBrick.uVar = newBrick.userVariable
                newBrick.xFormula = mapFormulaListToBrick(input: brick)?.lastObject as? Formula
                newBrick.yFormula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kHideTextBrick.uppercased():
                let newBrick = HideTextBrick()
                newBrick.userVariable = resolveUserVariable(project: project, object: object, script: script, brick: brick, isList: false)
                newBrick.uVar = newBrick.userVariable
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kAddItemToUserListBrick.uppercased():
                let newBrick = AddItemToUserListBrick()
                newBrick.userList = resolveUserVariable(project: project, object: object, script: script, brick: brick, isList: true)
                newBrick.uVar = newBrick.userList
                newBrick.listFormula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kDeleteItemOfUserListBrick.uppercased():
                let newBrick = DeleteItemOfUserListBrick()
                newBrick.userList = resolveUserVariable(project: project, object: object, script: script, brick: brick, isList: true)
                newBrick.uVar = newBrick.userList
                newBrick.listFormula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kInsertItemIntoUserListBrick.uppercased():
                let newBrick = InsertItemIntoUserListBrick()
                newBrick.userList = resolveUserVariable(project: project, object: object, script: script, brick: brick, isList: true)
                newBrick.uVar = newBrick.userList
                newBrick.index = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.elementFormula = mapFormulaListToBrick(input: brick)?.lastObject as? Formula
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kReplaceItemInUserListBrick.uppercased():
                let newBrick = ReplaceItemInUserListBrick()
                newBrick.userList = resolveUserVariable(project: project, object: object, script: script, brick: brick, isList: true)
                newBrick.uVar = newBrick.userList
                newBrick.elementFormula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.index = mapFormulaListToBrick(input: brick)?.lastObject as? Formula
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            // MARK: Arduino Bricks
            case kArduinoSendDigitalValueBrick.uppercased():
                let newBrick = ArduinoSendDigitalValueBrick()
                newBrick.pin = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.value = mapFormulaListToBrick(input: brick)?.lastObject as? Formula
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kArduinoSendPWMValueBrick.uppercased():
                let newBrick = ArduinoSendPWMValueBrick()
                newBrick.pin = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.value = mapFormulaListToBrick(input: brick)?.lastObject as? Formula
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            // MARK: Alternative Bricks
            case kComeToFrontBrick.uppercased():
                let newBrick = ComeToFrontBrick()
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kGoNStepsBackBrick.uppercased():
                let newBrick = GoNStepsBackBrick()
                newBrick.steps = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kSayBubbleBrick.uppercased():
                let newBrick = SayBubbleBrick()
                newBrick.formula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            case kSayForBubbleBrick.uppercased():
                let newBrick = SayForBubbleBrick()
                newBrick.stringFormula = mapFormulaListToBrick(input: brick)?.lastObject as? Formula
                newBrick.intFormula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
            default:
                let newBrick = NoteBrick()
                newBrick.note = String(format: "%@ %@", kLocalizedUnsupportedBrick, brick.type ?? "")
                newBrick.script = currentScript
                newBrick.commentedOut = brick.commentedOut
                resultBrickList.append(newBrick)
                unsupportedElements.append(brick.type ?? "")
            }
        }
        if resultBrickList.isEmpty { return nil }

        return NSMutableArray(array: resultBrickList)
    }

    static func mapGlideDestinations(input: CBBrick?, xDestination: Bool) -> NSMutableArray? {
        var formulaList = [Formula]()

        if let formulas = xDestination ? input?.xDestination?.formulas : input?.yDestination?.formulas {
            for formula in formulas {
                let mappedFormula = mapCBFormulaToFormula(input: formula)
                if formulaList.contains(mappedFormula) == false {
                    formulaList.append(mappedFormula)
                }
            }
        }

        return NSMutableArray(array: formulaList)
    }

    static func getLocalVariablesFromObject(project: CBProject?, object: CBObject?, isList: Bool) -> [String] {
        guard let project = project else { return [String]() }
        var localVariables = [String]()

        if let objctVariableList = project.scenes?.first?.data?.objectVariableList?.entry, isList == false {
            for entry in objctVariableList {
                let resolvedReference = resolveReferenceString(reference: entry.object, project: project)
                if let objectIndex = resolvedReference?.0 {
                    let referencedObject = project.scenes?.first?.objectList?.objects?[objectIndex]

                    if referencedObject?.name == object?.name, let entryList = entry.list {
                        for variable in entryList {
                            let resolvedVariableReference = resolveReferenceString(reference: variable.reference, project: project)
                            if let scIdx = resolvedVariableReference?.1, scIdx < referencedObject?.scriptList?.scripts?.count ?? 0 {
                                if let brIdx = resolvedVariableReference?.2, brIdx < referencedObject?.scriptList?.scripts?[scIdx].brickList?.bricks?.count ?? 0 {
                                    if let localVar = referencedObject?.scriptList?.scripts?[scIdx].brickList?.bricks?[brIdx].userVariable {
                                        localVariables.append(localVar)
                                    }
                                }
                            }
                        }
                        break
                    }
                }
            }
        }

        if let objctVariableList = project.scenes?.first?.data?.objectListOfList?.entry, isList == true {
            for entry in objctVariableList {
                let resolvedReference = resolveReferenceString(reference: entry.object, project: project)
                if let objectIndex = resolvedReference?.0 {
                    let referencedObject = project.scenes?.first?.objectList?.objects?[objectIndex]

                    if referencedObject?.name == object?.name, let entryList = entry.list {
                        for variable in entryList {
                            let resolvedVariableReference = resolveReferenceString(reference: variable.reference, project: project)
                            if let scIdx = resolvedVariableReference?.1, let brIdx = resolvedVariableReference?.2 {
                                if let localVar = referencedObject?.scriptList?.scripts?[scIdx].brickList?.bricks?[brIdx].userList {
                                    localVariables.append(localVar)
                                }
                            }
                        }
                        break
                    }
                }
            }
        }

        return localVariables
    }

    static func resolveUserVariable(project: CBProject?, object: CBObject?, script: CBScript?, brick: CBBrick?, isList: Bool) -> UserVariable? {
        guard let project = project else { return nil }
        guard let object = object else { return nil }
        guard let script = script else { return nil }
        guard let brick = brick else { return nil }

        if let reference = brick.userVariableReference {
            var splittedReference = reference.split(separator: "/")
            splittedReference = splittedReference.filter { $0 != ".." }
            if splittedReference.count == 2 {
                let resolvedReference = resolveReferenceStringExtraShort(reference: reference, project: project, script: script)
                if let bIdx = resolvedReference, let brickList = script.brickList?.bricks, bIdx < brickList.count, brickList[bIdx].userVariable != nil || brickList[bIdx].userList != nil {
                    return resolveUserVariable(project: project, object: object, script: script, brick: brickList[bIdx], isList: isList)
                }
            } else if splittedReference.count == 4 {
                let resolvedReference = resolveReferenceStringShort(reference: reference, project: project, object: object)
                if let sIdx = resolvedReference?.0, let bIdx = resolvedReference?.1 {
                    if let scriptList = object.scriptList?.scripts, sIdx < scriptList.count {
                        if let brickList = scriptList[sIdx].brickList?.bricks, bIdx < brickList.count, brickList[bIdx].userVariable != nil || brickList[bIdx].userList != nil {
                            return resolveUserVariable(project: project, object: object, script: script, brick: brickList[bIdx], isList: isList)
                        }
                    }
                }
            } else if splittedReference.count == 6 {
                let resolvedReference = resolveReferenceString(reference: reference, project: project)
                if let oIdx = resolvedReference?.0, let sIdx = resolvedReference?.1, let bIdx = resolvedReference?.2 {
                    if let objectList = project.scenes?.first?.objectList?.objects, oIdx < objectList.count {
                        if let scriptList = objectList[oIdx].scriptList?.scripts, sIdx < scriptList.count {
                            if let brickList = scriptList[sIdx].brickList?.bricks, bIdx < brickList.count, brickList[bIdx].userVariable != nil || brickList[bIdx].userList != nil {
                                return resolveUserVariable(project: project, object: object, script: script, brick: brickList[bIdx], isList: isList)
                            }
                        }
                    }
                }
            }
        } else if let variable = brick.userVariable {
            let localVariableNames = getLocalVariablesFromObject(project: project, object: object, isList: false)
            if let variable = brick.userVariable, localVariableNames.contains(variable) {
                return allocLocalUserVariable(name: variable, isList: false)
            }
            return allocUserVariable(name: variable, isList: false)
        } else if let variable = brick.userList {
            let localVariableNames = getLocalVariablesFromObject(project: project, object: object, isList: true)
            if let variable = brick.userList, localVariableNames.contains(variable) {
                return allocLocalUserVariable(name: variable, isList: true)
            }
            return allocUserVariable(name: variable, isList: true)
        }

        return nil
    }

    static func allocUserVariable(name: String, isList: Bool) -> UserVariable {
        for variable in mappingVariableListGlobal where variable.name == name && variable.isList == isList {
            return variable
        }

        let userVar = UserVariable()
        userVar.name = name
        userVar.isList = isList ? true : false
        mappingVariableListGlobal.append(userVar)
        return userVar
    }

    static func allocLocalUserVariable(name: String, isList: Bool) -> UserVariable {
        for variable in mappingVariableListLocal where variable.name == name && variable.isList == isList {
            return variable
        }

        let userVar = UserVariable()
        userVar.name = name
        userVar.isList = isList ? true : false
        mappingVariableListLocal.append(userVar)
        return userVar
    }

    // MARK: - mapFormula
    static func mapFormulaListToBrick(input: CBBrick?) -> NSMutableArray? {
        var formulaList = [Formula]()

        if let formulas = input?.formulaList?.formulas {
            for formula in formulas {
                let mappedFormula = mapCBFormulaToFormula(input: formula)
                if formulaList.contains(mappedFormula) == false {
                    formulaList.append(mappedFormula)
                }
            }
        } else if let formulas = input?.formulaTree?.formulas {
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

    static func mapXYDestinationsToBrick(input: CBBrick?) -> NSMutableArray? {
        var formulaList = [Formula]()

        if let xDestination = input?.xDestination?.formulas {
            for formula in xDestination {
                let mappedFormula = mapCBFormulaToFormula(input: formula)
                if formulaList.contains(mappedFormula) == false {
                    formulaList.append(mappedFormula)
                }
            }
        }

        if let yDestination = input?.yDestination?.formulas {
            for formula in yDestination {
                let mappedFormula = mapCBFormulaToFormula(input: formula)
                if formulaList.contains(mappedFormula) == false {
                    formulaList.append(mappedFormula)
                }
            }
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
        formula.category = input.category
        return formula
    }

    static func mapCBLRChildToFormulaTree(input: CBLRChild?, tree: FormulaElement) -> FormulaElement? {
        guard let input = input else { return nil }
        let child = FormulaElement(type: input.type, value: input.value, leftChild: nil, rightChild: nil, parent: nil)
        child?.parent = tree

        if let leftChild = input.leftChild.first, leftChild != nil, let ch = child {
            let leftChild = mapCBLRChildToFormulaTree(input: leftChild, tree: ch)
            child?.leftChild = leftChild
        }

        if let rightChild = input.rightChild.first, rightChild != nil, let ch = child {
            let rightChild = mapCBLRChildToFormulaTree(input: rightChild, tree: ch)
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
            if let scriptList = object.scriptList?.scripts {
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
            if let brickList = object.scriptList?.scripts?[scriptNr].brickList?.bricks {
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

        if scriptType.isEmpty == false && brickType.isEmpty == false, let objectList = project.scenes?.first?.objectList?.objects?[objectNr] {
            var abstractScriptNr = 0
            if let scriptList = objectList.scriptList?.scripts {
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
            if let brickList = objectList.scriptList?.scripts?[scriptNr].brickList?.bricks {
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
