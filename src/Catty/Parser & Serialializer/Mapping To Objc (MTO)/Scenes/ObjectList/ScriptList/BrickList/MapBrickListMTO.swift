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
                resultBrickList.append(BroadcastBrick(message: brick.broadcastMessage ?? ""))
            case kBroadcastWaitBrick.uppercased():
                resultBrickList.append(BroadcastWaitBrick(message: brick.broadcastMessage ?? ""))
            case kIfLogicBeginBrick.uppercased():
                let newBrick = IfLogicBeginBrick()
                newBrick.ifCondition = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.ifCondition?.category = "IF_CONDITION"
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
                resultBrickList.append(newBrick)
            case kIfThenLogicBeginBrick.uppercased():
                let newBrick = IfThenLogicBeginBrick()
                newBrick.ifCondition = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.ifCondition?.category = "IF_CONDITION"
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
                resultBrickList.append(newBrick)
            case kForeverBrick.uppercased():
                resultBrickList.append(ForeverBrick())
            case kRepeatBrick.uppercased():
                let newBrick = RepeatBrick()
                newBrick.timesToRepeat = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.timesToRepeat?.category = "TIMES_TO_REPEAT"
                resultBrickList.append(newBrick)
            case kRepeatUntilBrick.uppercased():
                let newBrick = RepeatUntilBrick()
                newBrick.repeatCondition = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.repeatCondition?.category = "REPEAT_UNTIL_CONDITION"
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
                resultBrickList.append(newBrick)
            case kNoteBrick.uppercased():
                let newBrick = NoteBrick()
                newBrick.note = brick.noteMessage
                resultBrickList.append(newBrick)
            case kWaitBrick.uppercased():
                let newBrick = WaitBrick()
                if let time = mapFormulaListToBrick(input: brick)?.firstObject as? Formula {
                    newBrick.timeToWaitInSeconds = time
                    newBrick.timeToWaitInSeconds.category = "TIME_TO_WAIT_IN_SECONDS"
                }
                resultBrickList.append(newBrick)
            case kWaitUntilBrick.uppercased():
                let newBrick = WaitUntilBrick()
                if let condition = mapFormulaListToBrick(input: brick)?.firstObject as? Formula {
                    newBrick.waitCondition = condition
                    newBrick.waitCondition?.category = "IF_CONDITION"
                }
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
                newBrick.xPosition?.category = "X_POSITION"
                newBrick.yPosition?.category = "Y_POSITION"
                resultBrickList.append(newBrick)
            case kChangeXByNBrick.uppercased():
                let newBrick = ChangeXByNBrick()
                newBrick.xMovement = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.xMovement?.category = "X_POSITION_CHANGE"
                resultBrickList.append(newBrick)
            case kChangeYByNBrick.uppercased():
                let newBrick = ChangeYByNBrick()
                newBrick.yMovement = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.yMovement?.category = "Y_POSITION_CHANGE"
                resultBrickList.append(newBrick)
            case kSetXBrick.uppercased():
                let newBrick = SetXBrick()
                newBrick.xPosition = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.xPosition?.category = "X_POSITION"
                resultBrickList.append(newBrick)
            case kSetYBrick.uppercased():
                let newBrick = SetYBrick()
                newBrick.yPosition = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.yPosition?.category = "Y_POSITION"
                resultBrickList.append(newBrick)
            case kIfOnEdgeBounceBrick.uppercased():
                resultBrickList.append(IfOnEdgeBounceBrick())
            case kMoveNStepsBrick.uppercased():
                let newBrick = MoveNStepsBrick()
                newBrick.steps = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.steps?.category = "STEPS"
                resultBrickList.append(newBrick)
            case kTurnLeftBrick.uppercased():
                let newBrick = TurnLeftBrick()
                newBrick.degrees = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.degrees?.category = "TURN_LEFT_DEGREES"
                resultBrickList.append(newBrick)
            case kTurnRightBrick.uppercased():
                let newBrick = TurnRightBrick()
                newBrick.degrees = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.degrees?.category = "TURN_RIGHT_DEGREES"
                resultBrickList.append(newBrick)
            case kPointInDirectionBrick.uppercased():
                let newBrick = PointInDirectionBrick()
                newBrick.degrees = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.degrees?.category = "DEGREES"
                resultBrickList.append(newBrick)
            case kPointToBrick.uppercased():
                let newBrick = PointToBrick()
                for object in objectList where object.name == brick.pointedObjectReference {
                    newBrick.pointedObject = mapObject(object: object, objectList: objectList, project: project, currentScene: currObject.scene)
                }
                if newBrick.pointedObject == nil, let pointed = brick.pointedObject {
                    newBrick.pointedObject = mapObject(object: pointed, objectList: objectList, project: project, currentScene: currObject.scene)
                }
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
                            newBrick.xDestination?.category = "X_DESTINATION"
                            orderArr.append("X")
                        case "Y_DESTINATION":
                            newBrick.yDestination = mappedFormula
                            newBrick.yDestination?.category = "Y_DESTINATION"
                            orderArr.append("Y")
                        default:
                            newBrick.durationInSeconds = mappedFormula
                            newBrick.durationInSeconds?.category = "DURATION_IN_SECONDS"
                            orderArr.append("D")
                        }
                    }
                }
                if newBrick.xDestination == nil || newBrick.yDestination == nil {
                    newBrick.xDestination = mapDestinations(input: brick, xDestination: true)?.firstObject as? Formula
                    newBrick.xDestination?.category = "X_DESTINATION"
                    newBrick.yDestination = mapDestinations(input: brick, xDestination: false)?.firstObject as? Formula
                    newBrick.yDestination?.category = "Y_DESTINATION"
                    orderArr.append("X")
                    orderArr.append("Y")
                }
                newBrick.serializationOrder = orderArr
                resultBrickList.append(newBrick)
            case kVibrationBrick.uppercased():
                let newBrick = VibrationBrick()
                newBrick.durationInSeconds = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.durationInSeconds?.category = "VIBRATE_DURATION_IN_SECONDS"
                resultBrickList.append(newBrick)
            // MARK: Look Bricks
            case kSetBackgroundBrick.uppercased():
                let newBrick = SetBackgroundBrick()
                let tmpSpriteObj = SpriteObject(scene: currObject.scene)!
                tmpSpriteObj.lookList = lookList
                newBrick.setDefaultValuesFor(tmpSpriteObj)
                if let range = brick.lookReference?.range(of: "[(0-9)*]", options: .regularExpression) {
                    let index = String(brick.lookReference?[range] ?? "")
                    if let index = Int(index), index <= lookList.count, index > 0 {
                        newBrick.look = lookList[index - 1] as? Look
                    }
                }
                resultBrickList.append(newBrick)
            case kSetLookBrick.uppercased():
                let newBrick = SetLookBrick()
                let tmpSpriteObj = SpriteObject(scene: currObject.scene)!
                tmpSpriteObj.lookList = lookList
                newBrick.setDefaultValuesFor(tmpSpriteObj)
                if let range = brick.lookReference?.range(of: "[(0-9)*]", options: .regularExpression) {
                    let index = String(brick.lookReference?[range] ?? "")
                    if let index = Int(index), index <= lookList.count, index > 0 {
                        newBrick.look = lookList[index - 1] as? Look
                    }
                }
                resultBrickList.append(newBrick)
            case kNextLookBrick.uppercased():
                resultBrickList.append(NextLookBrick())
            case kPreviousLookBrick.uppercased():
                resultBrickList.append(PreviousLookBrick())
            case kSetSizeToBrick.uppercased():
                let newBrick = SetSizeToBrick()
                newBrick.size = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.size?.category = "SIZE"
                resultBrickList.append(newBrick)
            case kChangeSizeByNBrick.uppercased():
                let newBrick = ChangeSizeByNBrick()
                newBrick.size = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.size?.category = "SIZE_CHANGE"
                resultBrickList.append(newBrick)
            case kShowBrick.uppercased():
                resultBrickList.append(ShowBrick())
            case kHideBrick.uppercased():
                resultBrickList.append(HideBrick())
            case kSetTransparencyBrick.uppercased(), kSetGhostEffectBrick.uppercased():
                let newBrick = SetTransparencyBrick()
                newBrick.transparency = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.transparency?.category = "TRANSPARENCY"
                resultBrickList.append(newBrick)
            case kChangeTransparencyByNBrick.uppercased(), kChangeGhostEffectByNBrick.uppercased():
                let newBrick = ChangeTransparencyByNBrick()
                newBrick.changeTransparency = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.changeTransparency?.category = "TRANSPARENCY_CHANGE"
                resultBrickList.append(newBrick)
            case kSetBrightnessBrick.uppercased():
                let newBrick = SetBrightnessBrick()
                newBrick.brightness = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.brightness?.category = "BRIGHTNESS"
                resultBrickList.append(newBrick)
            case kChangeBrightnessByNBrick.uppercased():
                let newBrick = ChangeBrightnessByNBrick()
                newBrick.changeBrightness = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.changeBrightness?.category = "BRIGHTNESS_CHANGE"
                resultBrickList.append(newBrick)
            case kSetColorBrick.uppercased():
                let newBrick = SetColorBrick()
                newBrick.color = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.color?.category = "COLOR"
                resultBrickList.append(newBrick)
            case kChangeColorByNBrick.uppercased():
                let newBrick = ChangeColorByNBrick()
                newBrick.changeColor = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.changeColor?.category = "COLOR_CHANGE"
                resultBrickList.append(newBrick)
            case kClearGraphicEffectBrick.uppercased():
                resultBrickList.append(ClearGraphicEffectBrick())
            case kFlashBrick.uppercased(), kLedOnBrick.uppercased(), kLedOffBrick.uppercased():
                var newBrick = FlashBrick()
                if let flashState = brick.spinnerSelectionID {
                    newBrick = FlashBrick(choice: Int32(flashState) ?? 0)
                }
                resultBrickList.append(newBrick)
            case kCameraBrick.uppercased():
                var newBrick = CameraBrick()
                if let cameraState = brick.spinnerSelectionID {
                    newBrick = CameraBrick(choice: Int32(cameraState) ?? 0)
                }
                resultBrickList.append(newBrick)
            case kChooseCameraBrick.uppercased():
                var newBrick = ChooseCameraBrick()
                if let cameraState = brick.spinnerSelectionID {
                    newBrick = ChooseCameraBrick(choice: Int32(cameraState) ?? 0)
                }
                resultBrickList.append(newBrick)
            case kThinkBubbleBrick.uppercased():
                let newBrick = ThinkBubbleBrick()
                newBrick.formula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.formula?.category = "STRING"
                resultBrickList.append(newBrick)
            case kThinkForBubbleBrick.uppercased():
                let newBrick = ThinkForBubbleBrick()
                newBrick.stringFormula = mapFormulaListToBrick(input: brick)?.lastObject as? Formula
                newBrick.stringFormula?.category = "STRING"
                newBrick.intFormula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.intFormula?.category = "DURATION_IN_SECONDS"
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
                resultBrickList.append(newBrick)
            case kStopAllSoundsBrick.uppercased():
                resultBrickList.append(StopAllSoundsBrick())
            case kSetVolumeToBrick.uppercased():
                let newBrick = SetVolumeToBrick()
                newBrick.volume = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.volume?.category = "VOLUME"
                resultBrickList.append(newBrick)
            case kChangeVolumeByNBrick.uppercased():
                let newBrick = ChangeVolumeByNBrick()
                newBrick.volume = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.volume?.category = "VOLUME_CHANGE"
                resultBrickList.append(newBrick)
            case kSpeakBrick.uppercased():
                let newBrick = SpeakBrick()
                newBrick.formula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.formula?.category = "SPEAK"
                newBrick.text = brick.noteMessage
                resultBrickList.append(newBrick)
            case kSpeakAndWaitBrick.uppercased():
                let newBrick = SpeakAndWaitBrick()
                newBrick.formula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.formula?.category = "SPEAK"
                newBrick.text = brick.noteMessage
                resultBrickList.append(newBrick)
            // MARK: Variable Bricks
            case kSetVariableBrick.uppercased():
                let newBrick = SetVariableBrick()
                newBrick.userVariable = resolveUserVariable(project: project, object: object, script: script, brick: brick, isList: false)
                newBrick.uVar = newBrick.userVariable
                newBrick.variableFormula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.variableFormula?.category = "VARIABLE"
                resultBrickList.append(newBrick)
            case kChangeVariableBrick.uppercased():
                let newBrick = ChangeVariableBrick()
                newBrick.userVariable = resolveUserVariable(project: project, object: object, script: script, brick: brick, isList: false)
                newBrick.uVar = newBrick.userVariable
                newBrick.variableFormula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.variableFormula?.category = "VARIABLE_CHANGE"
                resultBrickList.append(newBrick)
            case kShowTextBrick.uppercased():
                let newBrick = ShowTextBrick()
                newBrick.userVariable = resolveUserVariable(project: project, object: object, script: script, brick: brick, isList: false)
                newBrick.uVar = newBrick.userVariable
                newBrick.xFormula = mapFormulaListToBrick(input: brick)?.lastObject as? Formula
                newBrick.yFormula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.xFormula?.category = "X_POSITION"
                newBrick.yFormula?.category = "Y_POSITION"
                resultBrickList.append(newBrick)
            case kHideTextBrick.uppercased():
                let newBrick = HideTextBrick()
                newBrick.userVariable = resolveUserVariable(project: project, object: object, script: script, brick: brick, isList: false)
                newBrick.uVar = newBrick.userVariable
                resultBrickList.append(newBrick)
            case kAddItemToUserListBrick.uppercased():
                let newBrick = AddItemToUserListBrick()
                newBrick.userList = resolveUserVariable(project: project, object: object, script: script, brick: brick, isList: true)
                newBrick.uVar = newBrick.userList
                newBrick.listFormula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.listFormula?.category = "LIST_ADD_ITEM"
                resultBrickList.append(newBrick)
            case kDeleteItemOfUserListBrick.uppercased():
                let newBrick = DeleteItemOfUserListBrick()
                newBrick.userList = resolveUserVariable(project: project, object: object, script: script, brick: brick, isList: true)
                newBrick.uVar = newBrick.userList
                newBrick.listFormula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.listFormula?.category = "LIST_DELETE_ITEM"
                resultBrickList.append(newBrick)
            case kInsertItemIntoUserListBrick.uppercased():
                let newBrick = InsertItemIntoUserListBrick()
                newBrick.userList = resolveUserVariable(project: project, object: object, script: script, brick: brick, isList: true)
                newBrick.uVar = newBrick.userList
                newBrick.index = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.index?.category = "INSERT_ITEM_INTO_USERLIST_INDEX"
                newBrick.elementFormula = mapFormulaListToBrick(input: brick)?.lastObject as? Formula
                newBrick.elementFormula?.category = "INSERT_ITEM_INTO_USERLIST_VALUE"
                resultBrickList.append(newBrick)
            case kReplaceItemInUserListBrick.uppercased():
                let newBrick = ReplaceItemInUserListBrick()
                newBrick.userList = resolveUserVariable(project: project, object: object, script: script, brick: brick, isList: true)
                newBrick.uVar = newBrick.userList
                newBrick.elementFormula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.elementFormula?.category = "REPLACE_ITEM_IN_USERLIST_VALUE"
                newBrick.index = mapFormulaListToBrick(input: brick)?.lastObject as? Formula
                newBrick.index?.category = "REPLACE_ITEM_IN_USERLIST_INDEX"
                resultBrickList.append(newBrick)
            // MARK: Arduino Bricks
            case kArduinoSendDigitalValueBrick.uppercased():
                let newBrick = ArduinoSendDigitalValueBrick()
                newBrick.pin = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.pin?.category = "ARDUINO_DIGITAL_PIN_NUMBER"
                newBrick.value = mapFormulaListToBrick(input: brick)?.lastObject as? Formula
                newBrick.value?.category = "ARDUINO_DIGITAL_PIN_VALUE"
                resultBrickList.append(newBrick)
            case kArduinoSendPWMValueBrick.uppercased():
                let newBrick = ArduinoSendPWMValueBrick()
                newBrick.pin = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.pin?.category = "ARDUINO_ANALOG_PIN_NUMBER"
                newBrick.value = mapFormulaListToBrick(input: brick)?.lastObject as? Formula
                newBrick.value?.category = "ARDUINO_ANALOG_PIN_VALUE"
                resultBrickList.append(newBrick)
            // MARK: Alternative Bricks
            case kComeToFrontBrick.uppercased():
                resultBrickList.append(ComeToFrontBrick())
            case kGoNStepsBackBrick.uppercased():
                let newBrick = GoNStepsBackBrick()
                newBrick.steps = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.steps?.category = "STEPS"
                resultBrickList.append(newBrick)
            case kSayBubbleBrick.uppercased():
                let newBrick = SayBubbleBrick()
                newBrick.formula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.formula?.category = "STRING"
                resultBrickList.append(newBrick)
            case kSayForBubbleBrick.uppercased():
                let newBrick = SayForBubbleBrick()
                newBrick.stringFormula = mapFormulaListToBrick(input: brick)?.lastObject as? Formula
                newBrick.stringFormula?.category = "STRING"
                newBrick.intFormula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.intFormula?.category = "DURATION_IN_SECONDS"
                resultBrickList.append(newBrick)
            default:
                let newBrick = NoteBrick()
                newBrick.note = String(format: "%@ %@", kLocalizedUnsupportedBrick, brick.type ?? "")
                resultBrickList.append(newBrick)
                unsupportedElements.append(brick.type ?? "")
            }
            resultBrickList.last?.script = currentScript
            resultBrickList.last?.commentedOut = brick.commentedOut
        }
        if resultBrickList.isEmpty { return nil }

        return NSMutableArray(array: resultBrickList)
    }
}
