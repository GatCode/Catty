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

extension CBXMLMapping {

    // MARK: - mapObjectList
    static func mapObjectList(project: CBProject?, currentProject: inout Project) -> NSMutableArray? {
        guard let project = project else { return nil }
        guard let objectList = project.scenes?.first?.objectList?.object else { return nil } // TODO: NOW ONLY WORKING WITH ONE SCENE!!!

        var resultObjectList = [SpriteObject]()
        for object in objectList {
            if let mappedObject = mapObject(object: object, objectList: objectList, project: project) {
                mappedObject.project = currentProject
                resultObjectList.append(mappedObject)
            }
        }
        if resultObjectList.isEmpty { return nil }

        return NSMutableArray(array: resultObjectList)
    }

    static func mapObject(object: CBObject?, objectList: [CBObject]?, project: CBProject?) -> SpriteObject? {
        guard let object = object else { return nil }
        guard let project = project else { return nil }
        guard let lookList = object.lookList else { return nil }
        guard let soundList = object.soundList else { return nil }

        var result = SpriteObject()
        result.name = object.name
        result.lookList = mapLookList(lookList: lookList)
        result.soundList = mapSoundList(soundList: soundList, project: project, object: object)
        result.scriptList = mapScriptList(object: object, objectList: objectList, project: project, currentObject: &result)
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

        for look in mappingLookList where look.name == newLook.name && look.fileName == newLook.fileName {
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
    static func mapScriptList(object: CBObject?, objectList: [CBObject]?, project: CBProject?, currentObject: inout SpriteObject) -> NSMutableArray? {
        guard let scriptList = object?.scriptList?.script else { return nil }

        var resultScriptList = [Script]()
        for script in scriptList {
            if let scr = mapScript(script: script, objectList: objectList, object: object, project: project, currentObject: &currentObject) {
                scr.object = currentObject
                resultScriptList.append(scr)
            }
        }
        if resultScriptList.isEmpty { return nil }

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
            if let msg = allocBroadcastMessage(message: script.receivedMessage) {
                scr.receivedMessage = msg
            }
            result = scr
        default:
            if script.type?.hasSuffix(kScript) ?? false {
                let scr = BroadcastScript()
                if let type = script.type {
                    let msg = allocBroadcastMessage(message: String(format: "%@ %@", "timeNow in hex: ", kLocalizedUnsupportedScript, type))
                    scr.receivedMessage = msg
                }
                result = scr
            }
        }

        if let res = result {
            res.brickList = mapBrickList(script: script, objectList: objectList, object: object, project: project, currScript: &result, currObject: &currentObject)
            return res.brickList != nil ? result : nil
        }

        return nil
    }

    static func allocBroadcastMessage(message: String?) -> String? {
        guard let message = message else { return nil }

        for msg in mappingBroadcastList where msg == message {
            return msg
        }

        mappingBroadcastList.append(message)
        return message
    }

    // MARK: - mapBrickList
    static func mapBrickList(script: CBScript?, objectList: [CBObject]?, object: CBObject?, project: CBProject?, currScript: inout Script?, currObject: inout SpriteObject) -> NSMutableArray? {
        guard let brickList = script?.brickList?.brick else { return nil }
        guard let lookList = currObject.lookList else { return nil }
        guard let currentScript = currScript else { return nil }
        guard let objectList = objectList else { return nil }

        var resultBrickList = [Brick]()
        for brick in brickList {
            switch brick.type?.uppercased() {
            // MARK: Condition Bricks
            case kBroadcastBrick.uppercased():
                let newBrick = BroadcastBrick()
                if let msg = allocBroadcastMessage(message: brick.broadcastMessage) {
                    newBrick.broadcastMessage = msg
                }
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kBroadcastWaitBrick.uppercased():
                let newBrick = BroadcastWaitBrick()
                if let msg = allocBroadcastMessage(message: brick.broadcastMessage) {
                    newBrick.broadcastMessage = msg
                }
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kIfLogicBeginBrick.uppercased():
                let newBrick = IfLogicBeginBrick()
                newBrick.ifCondition = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kIfLogicElseBrick.uppercased():
                let newBrick = IfLogicElseBrick()
                for item in resultBrickList.reversed() where item.brickType == kBrickType.ifBrick {
                    newBrick.ifBeginBrick = item as? IfLogicBeginBrick
                    (item as? IfLogicBeginBrick)?.ifElseBrick = newBrick
                }
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kIfLogicEndBrick.uppercased():
                let newBrick = IfLogicEndBrick()
                for item in resultBrickList.reversed() where item.brickType == kBrickType.ifElseBrick {
                    newBrick.ifBeginBrick = (item as? IfLogicElseBrick)?.ifBeginBrick
                    newBrick.ifElseBrick = item as? IfLogicElseBrick
                    (item as? IfLogicElseBrick)?.ifBeginBrick.ifEndBrick = newBrick
                    (item as? IfLogicElseBrick)?.ifEndBrick = newBrick
                }
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kIfThenLogicBeginBrick.uppercased():
                let newBrick = IfThenLogicBeginBrick()
                newBrick.ifCondition = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kIfThenLogicEndBrick.uppercased():
                let newBrick = IfThenLogicEndBrick()
                for item in resultBrickList.reversed() where item.brickType == kBrickType.ifThenBrick {
                    newBrick.ifBeginBrick = item as? IfThenLogicBeginBrick
                    (item as? IfThenLogicBeginBrick)?.ifEndBrick = newBrick
                }
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kForeverBrick.uppercased():
                let newBrick = ForeverBrick()
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kRepeatBrick.uppercased():
                let newBrick = RepeatBrick()
                newBrick.timesToRepeat = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kRepeatUntilBrick.uppercased():
                let newBrick = RepeatUntilBrick()
                newBrick.repeatCondition = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kLoopEndBrick.uppercased(), kLoopEndlessBrick.uppercased():
                let newBrick = LoopEndBrick()
                for item in resultBrickList.reversed() {
                    newBrick.loopBeginBrick = item as? LoopBeginBrick

                    if item.brickType == kBrickType.repeatBrick {
                        (item as? RepeatBrick)?.loopEndBrick = newBrick
                        break
                    } else if item.brickType == kBrickType.repeatUntilBrick {
                        (item as? RepeatUntilBrick)?.loopEndBrick = newBrick
                        break
                    } else if item.brickType == kBrickType.foreverBrick {
                        (item as? ForeverBrick)?.loopEndBrick = newBrick
                        break
                    }
                }
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kNoteBrick.uppercased():
                let newBrick = NoteBrick()
                newBrick.note = brick.noteMessage
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kWaitBrick.uppercased():
                let newBrick = WaitBrick()
                if let time = mapFormulaListToBrick(input: brick)?.firstObject as? Formula {
                    newBrick.timeToWaitInSeconds = time
                }
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kWaitUntilBrick.uppercased():
                let newBrick = WaitUntilBrick()
                if let condition = mapFormulaListToBrick(input: brick)?.firstObject as? Formula {
                    newBrick.waitCondition = condition
                }
                newBrick.script = currentScript
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
                resultBrickList.append(newBrick)
            case kChangeXByNBrick.uppercased():
                let newBrick = ChangeXByNBrick()
                newBrick.xMovement = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kChangeYByNBrick.uppercased():
                let newBrick = ChangeYByNBrick()
                newBrick.yMovement = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kSetXBrick.uppercased():
                let newBrick = SetXBrick()
                newBrick.xPosition = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kSetYBrick.uppercased():
                let newBrick = SetYBrick()
                newBrick.yPosition = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kIfOnEdgeBounceBrick.uppercased():
                let newBrick = IfOnEdgeBounceBrick()
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kMoveNStepsBrick.uppercased():
                let newBrick = MoveNStepsBrick()
                newBrick.steps = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kTurnLeftBrick.uppercased():
                let newBrick = TurnLeftBrick()
                newBrick.degrees = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kTurnRightBrick.uppercased():
                let newBrick = TurnRightBrick()
                newBrick.degrees = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kPointInDirectionBrick.uppercased():
                let newBrick = PointInDirectionBrick()
                newBrick.degrees = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kPointToBrick.uppercased():
                let newBrick = PointToBrick()
                for object in objectList where object.name == brick.pointedObject {
                    newBrick.pointedObject = mapObject(object: object, objectList: objectList, project: project)
                }
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kGlideToBrick.uppercased():
                let newBrick = GlideToBrick()
                let formulaTreeMapping = mapFormulaListToBrick(input: brick)
                guard let formulaMapping = formulaTreeMapping else { break }
                newBrick.durationInSeconds = formulaMapping.firstObject as? Formula
                if formulaMapping.count >= 3 {
                    newBrick.yDestination = formulaMapping[1] as? Formula
                    newBrick.xDestination = formulaMapping[2] as? Formula
                } else {
                    newBrick.yDestination = mapGlideDestinations(input: brick, xDestination: true)?.firstObject as? Formula
                    newBrick.xDestination = mapGlideDestinations(input: brick, xDestination: false)?.lastObject as? Formula
                }
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kVibrationBrick.uppercased():
                let newBrick = VibrationBrick()
                newBrick.durationInSeconds = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
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
                resultBrickList.append(newBrick)
            case kNextLookBrick.uppercased():
                let newBrick = NextLookBrick()
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kPreviousLookBrick.uppercased():
                let newBrick = PreviousLookBrick()
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kSetSizeToBrick.uppercased():
                let newBrick = SetSizeToBrick()
                newBrick.size = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kChangeSizeByNBrick.uppercased():
                let newBrick = ChangeSizeByNBrick()
                newBrick.size = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kShowBrick.uppercased():
                let newBrick = ShowBrick()
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kHideBrick.uppercased():
                let newBrick = HideBrick()
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kSetTransparencyBrick.uppercased(), kSetGhostEffectBrick.uppercased():
                let newBrick = SetTransparencyBrick()
                newBrick.transparency = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kChangeTransparencyByNBrick.uppercased(), kChangeGhostEffectByNBrick.uppercased():
                let newBrick = ChangeTransparencyByNBrick()
                newBrick.changeTransparency = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kSetBrightnessBrick.uppercased():
                let newBrick = SetBrightnessBrick()
                newBrick.brightness = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kChangeBrightnessByNBrick.uppercased():
                let newBrick = ChangeBrightnessByNBrick()
                newBrick.changeBrightness = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kSetColorBrick.uppercased():
                let newBrick = SetColorBrick()
                newBrick.color = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kChangeColorByNBrick.uppercased():
                let newBrick = ChangeColorByNBrick()
                newBrick.changeColor = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kClearGraphicEffectBrick.uppercased():
                let newBrick = ClearGraphicEffectBrick()
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kFlashBrick.uppercased(), kLedOnBrick.uppercased(), kLedOffBrick.uppercased():
                var newBrick = FlashBrick()
                if let flashState = brick.spinnerSelectionID {
                    newBrick = FlashBrick(choice: Int32(flashState) ?? 0)
                }
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kCameraBrick.uppercased():
                var newBrick = CameraBrick()
                if let cameraState = brick.spinnerSelectionID {
                    newBrick = CameraBrick(choice: Int32(cameraState) ?? 0)
                }
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kChooseCameraBrick.uppercased():
                var newBrick = ChooseCameraBrick()
                if let cameraState = brick.spinnerSelectionID {
                    newBrick = ChooseCameraBrick(choice: Int32(cameraState) ?? 0)
                }
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            // MARK: Sound Bricks
            case kPlaySoundBrick.uppercased():
                let newBrick = PlaySoundBrick()
                if let soundReference = brick.soundReference {
                    var splittedReference = soundReference.split(separator: "/")
                    splittedReference.forEach { if $0 == ".." { splittedReference.removeObject($0) } }
                    if splittedReference.count == 2, let soundString = splittedReference.last {
                        let soundIndex = extractNumberInBacesFrom(string: String(soundString))
                        if let newSoundList = object?.soundList?.sound, soundIndex < newSoundList.count {
                            for sound in mappingSoundList where sound.name == newSoundList[soundIndex].name {
                                newBrick.sound = sound
                            }
                        }
                    } else {
                        print("ERROR MAPPING PLAYSOUNDBRICK")
                    }
                } else {
                    for sound in mappingSoundList where sound.name == brick.sound?.name {
                        newBrick.sound = sound
                    }
                }
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kStopAllSoundsBrick.uppercased():
                let newBrick = StopAllSoundsBrick()
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kSetVolumeToBrick.uppercased():
                let newBrick = SetVolumeToBrick()
                newBrick.volume = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kChangeVolumeByNBrick.uppercased():
                let newBrick = ChangeVolumeByNBrick()
                newBrick.volume = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kSpeakBrick.uppercased():
                let newBrick = SpeakBrick()
                newBrick.formula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.text = brick.noteMessage
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kSpeakAndWaitBrick.uppercased():
                let newBrick = SpeakAndWaitBrick()
                newBrick.formula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.text = brick.noteMessage
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            // MARK: Variable Bricks
            case kSetVariableBrick.uppercased():
                let newBrick = SetVariableBrick()
                newBrick.userVariable = resolveUserVariable(project: project, object: object, script: script, brick: brick)
                newBrick.uVar = newBrick.userVariable
                newBrick.variableFormula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kChangeVariableBrick.uppercased():
                let newBrick = ChangeVariableBrick()
                newBrick.userVariable = resolveUserVariable(project: project, object: object, script: script, brick: brick)
                newBrick.uVar = newBrick.userVariable
                newBrick.variableFormula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kShowTextBrick.uppercased():
                let newBrick = ShowTextBrick()
                newBrick.userVariable = resolveUserVariable(project: project, object: object, script: script, brick: brick)
                newBrick.uVar = newBrick.userVariable
                newBrick.xFormula = mapFormulaListToBrick(input: brick)?.lastObject as? Formula
                newBrick.yFormula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kHideTextBrick.uppercased():
                let newBrick = HideTextBrick()
                newBrick.userVariable = resolveUserVariable(project: project, object: object, script: script, brick: brick)
                newBrick.uVar = newBrick.userVariable
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kAddItemToUserListBrick.uppercased():
                let newBrick = AddItemToUserListBrick()
                newBrick.userList = resolveUserVariable(project: project, object: object, script: script, brick: brick)
                newBrick.uVar = newBrick.userList
                newBrick.listFormula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kDeleteItemOfUserListBrick.uppercased():
                let newBrick = DeleteItemOfUserListBrick()
                newBrick.userList = resolveUserVariable(project: project, object: object, script: script, brick: brick)
                newBrick.uVar = newBrick.userList
                newBrick.listFormula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kInsertItemIntoUserListBrick.uppercased():
                let newBrick = InsertItemIntoUserListBrick()
                newBrick.userList = resolveUserVariable(project: project, object: object, script: script, brick: brick)
                newBrick.uVar = newBrick.userList
                newBrick.index = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.elementFormula = mapFormulaListToBrick(input: brick)?.lastObject as? Formula
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kReplaceItemInUserListBrick.uppercased():
                let newBrick = ReplaceItemInUserListBrick()
                newBrick.userList = resolveUserVariable(project: project, object: object, script: script, brick: brick)
                newBrick.uVar = newBrick.userList
                newBrick.elementFormula = mapFormulaListToBrick(input: brick)?.lastObject as? Formula
                newBrick.index = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            // MARK: Alternative Bricks
            case kComeToFrontBrick.uppercased():
                let newBrick = ComeToFrontBrick()
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            case kGoNStepsBackBrick.uppercased():
                let newBrick = GoNStepsBackBrick()
                newBrick.steps = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.script = currentScript
                resultBrickList.append(newBrick)
            default:
                print("UNSUPPORTED BRICK!!!")
            }
        }
        if resultBrickList.isEmpty { return nil }

        return NSMutableArray(array: resultBrickList)
    }

    static func mapGlideDestinations(input: CBBrick?, xDestination: Bool) -> NSMutableArray? {
        var formulaList = [Formula]()

        if let formulas = xDestination ? input?.xDestination?.formula : input?.yDestination?.formula {
            for formula in formulas {
                let mappedFormula = mapCBFormulaToFormula(input: formula)
                if formulaList.contains(mappedFormula) == false {
                    formulaList.append(mappedFormula)
                }
            }
        }

        return NSMutableArray(array: formulaList)
    }

    static func resolveUserVariable(project: CBProject?, object: CBObject?, script: CBScript?, brick: CBBrick?) -> UserVariable? {
        guard let project = project else { return nil }
        guard let object = object else { return nil }
        guard let script = script else { return nil }
        guard let brick = brick else { return nil }

        if let reference = brick.userVariableReference {
            var splittedReference = reference.split(separator: "/")
            splittedReference.forEach { if $0 == ".." { splittedReference.removeObject($0) } }
            if splittedReference.count == 2 {
                let resolvedReference = resolveReferenceStringExtraShort(reference: reference, project: project, script: script)
                if let bIdx = resolvedReference, let brickList = script.brickList?.brick, bIdx < brickList.count {
                    return resolveUserVariable(project: project, object: object, script: script, brick: brickList[bIdx])
                }
            } else if splittedReference.count == 4 {
                let resolvedReference = resolveReferenceStringShort(reference: reference, project: project, object: object)
                if let sIdx = resolvedReference?.0, let bIdx = resolvedReference?.1 {
                    if let scriptList = object.scriptList?.script, sIdx < scriptList.count {
                        if let brickList = scriptList[sIdx].brickList?.brick, bIdx < brickList.count {
                            return resolveUserVariable(project: project, object: object, script: script, brick: brickList[bIdx])
                        }
                    }
                }
            } else if splittedReference.count == 6 {
                let resolvedReference = resolveReferenceString(reference: reference, project: project)
                if let oIdx = resolvedReference?.0, let sIdx = resolvedReference?.1, let bIdx = resolvedReference?.2 {
                    if let objectList = project.scenes?.first?.objectList?.object, oIdx < objectList.count {
                        if let scriptList = objectList[oIdx].scriptList?.script, sIdx < scriptList.count {
                            if let brickList = scriptList[sIdx].brickList?.brick, bIdx < brickList.count {
                                return resolveUserVariable(project: project, object: object, script: script, brick: brickList[bIdx])
                            }
                        }
                    }
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
        for variable in mappingVariableList where variable.name == name {
            return variable
        }

        let userVar = UserVariable()
        userVar.name = name
        userVar.isList = isList ? true : false
        mappingVariableList.append(userVar)
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

        if scriptType.isEmpty == false && brickType.isEmpty == false, let objectList = project.scenes?.first?.objectList?.object?[objectNr] {
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
