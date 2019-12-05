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
            case BroadcastBrick().xmlTag()?.uppercased():
                resultBrickList.append(BroadcastBrick(message: brick.broadcastMessage ?? ""))
            case BroadcastWaitBrick().xmlTag()?.uppercased():
                resultBrickList.append(BroadcastWaitBrick(message: brick.broadcastMessage ?? ""))
            case IfLogicBeginBrick().xmlTag()?.uppercased():
                let newBrick = IfLogicBeginBrick()
                newBrick.ifCondition = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.ifCondition?.category = "IF_CONDITION"
                resultBrickList.append(newBrick)
            case IfLogicElseBrick().xmlTag()?.uppercased():
                let newBrick = IfLogicElseBrick()
                for item in resultBrickList.reversed() {// where item.brickType == kBrickType.ifBrick {
                    if let item = item as? IfLogicBeginBrick, item.ifElseBrick == nil {
                        newBrick.ifBeginBrick = item
                        item.ifElseBrick = newBrick
                        break
                    }
                }
                resultBrickList.append(newBrick)
            case IfLogicEndBrick().xmlTag()?.uppercased():
                let newBrick = IfLogicEndBrick()
                for item in resultBrickList.reversed() {// where item.brickType == kBrickType.ifElseBrick {
                    if let item = item as? IfLogicElseBrick, item.ifEndBrick == nil {
                        newBrick.ifBeginBrick = item.ifBeginBrick
                        newBrick.ifElseBrick = item
                        item.ifBeginBrick.ifEndBrick = newBrick
                        item.ifEndBrick = newBrick
                        break
                    }
                }
                resultBrickList.append(newBrick)
            case IfThenLogicBeginBrick().xmlTag()?.uppercased():
                let newBrick = IfThenLogicBeginBrick()
                newBrick.ifCondition = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.ifCondition?.category = "IF_CONDITION"
                resultBrickList.append(newBrick)
            case IfThenLogicEndBrick().xmlTag()?.uppercased():
                let newBrick = IfThenLogicEndBrick()
                for item in resultBrickList.reversed() {// where item.brickType == kBrickType.ifThenBrick {
                    if let item = item as? IfThenLogicBeginBrick, item.ifEndBrick == nil {
                        newBrick.ifBeginBrick = item
                        item.ifEndBrick = newBrick
                        break
                    }
                }
                resultBrickList.append(newBrick)
            case ForeverBrick().xmlTag()?.uppercased():
                resultBrickList.append(ForeverBrick())
            case RepeatBrick().xmlTag()?.uppercased():
                let newBrick = RepeatBrick()
                newBrick.timesToRepeat = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.timesToRepeat?.category = "TIMES_TO_REPEAT"
                resultBrickList.append(newBrick)
            case RepeatUntilBrick().xmlTag()?.uppercased():
                let newBrick = RepeatUntilBrick()
                newBrick.repeatCondition = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.repeatCondition?.category = "REPEAT_UNTIL_CONDITION"
                resultBrickList.append(newBrick)
            case LoopEndBrick().xmlTag()?.uppercased(), "LOPENDLESSBRICK":
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
            case NoteBrick().xmlTag()?.uppercased():
                let newBrick = NoteBrick()
                newBrick.note = brick.noteMessage
                resultBrickList.append(newBrick)
            case WaitBrick().xmlTag()?.uppercased():
                let newBrick = WaitBrick()
                if let time = mapFormulaListToBrick(input: brick)?.firstObject as? Formula {
                    newBrick.timeToWaitInSeconds = time
                    newBrick.timeToWaitInSeconds.category = "TIME_TO_WAIT_IN_SECONDS"
                }
                resultBrickList.append(newBrick)
            case WaitUntilBrick().xmlTag()?.uppercased():
                let newBrick = WaitUntilBrick()
                if let condition = mapFormulaListToBrick(input: brick)?.firstObject as? Formula {
                    newBrick.waitCondition = condition
                    newBrick.waitCondition?.category = "IF_CONDITION"
                }
                resultBrickList.append(newBrick)
            // MARK: Motion Bricks
            case PlaceAtBrick().xmlTag()?.uppercased():
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
            case ChangeXByNBrick().xmlTag()?.uppercased():
                let newBrick = ChangeXByNBrick()
                newBrick.xMovement = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.xMovement?.category = "X_POSITION_CHANGE"
                resultBrickList.append(newBrick)
            case ChangeYByNBrick().xmlTag()?.uppercased():
                let newBrick = ChangeYByNBrick()
                newBrick.yMovement = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.yMovement?.category = "Y_POSITION_CHANGE"
                resultBrickList.append(newBrick)
            case SetXBrick().xmlTag()?.uppercased():
                let newBrick = SetXBrick()
                newBrick.xPosition = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.xPosition?.category = "X_POSITION"
                resultBrickList.append(newBrick)
            case SetYBrick().xmlTag()?.uppercased():
                let newBrick = SetYBrick()
                newBrick.yPosition = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.yPosition?.category = "Y_POSITION"
                resultBrickList.append(newBrick)
            case IfOnEdgeBounceBrick().xmlTag()?.uppercased():
                resultBrickList.append(IfOnEdgeBounceBrick())
            case MoveNStepsBrick().xmlTag()?.uppercased():
                let newBrick = MoveNStepsBrick()
                newBrick.steps = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.steps?.category = "STEPS"
                resultBrickList.append(newBrick)
            case TurnLeftBrick().xmlTag()?.uppercased():
                let newBrick = TurnLeftBrick()
                newBrick.degrees = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.degrees?.category = "TURN_LEFT_DEGREES"
                resultBrickList.append(newBrick)
            case TurnRightBrick().xmlTag()?.uppercased():
                let newBrick = TurnRightBrick()
                newBrick.degrees = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.degrees?.category = "TURN_RIGHT_DEGREES"
                resultBrickList.append(newBrick)
            case PointInDirectionBrick().xmlTag()?.uppercased():
                let newBrick = PointInDirectionBrick()
                newBrick.degrees = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.degrees?.category = "DEGREES"
                resultBrickList.append(newBrick)
            case PointToBrick().xmlTag()?.uppercased():
                let newBrick = PointToBrick()
                for object in objectList where object.name == brick.pointedObjectReference {
                    newBrick.pointedObject = mapObject(object: object, objectList: objectList, project: project)
                }
                if newBrick.pointedObject == nil, let pointed = brick.pointedObject {
                    newBrick.pointedObject = mapObject(object: pointed, objectList: objectList, project: project)
                }
                resultBrickList.append(newBrick)
            case GlideToBrick().xmlTag()?.uppercased():
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
                //newBrick.serializationOrder = orderArr
                resultBrickList.append(newBrick)
            case VibrationBrick().xmlTag()?.uppercased():
                let newBrick = VibrationBrick()
                newBrick.durationInSeconds = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.durationInSeconds?.category = "VIBRATE_DURATION_IN_SECONDS"
                resultBrickList.append(newBrick)
            // MARK: Look Bricks
            case SetBackgroundBrick().xmlTag()?.uppercased():
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
                resultBrickList.append(newBrick)
            case SetLookBrick().xmlTag()?.uppercased():
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
                resultBrickList.append(newBrick)
            case NextLookBrick().xmlTag()?.uppercased():
                resultBrickList.append(NextLookBrick())
            case PreviousLookBrick().xmlTag()?.uppercased():
                resultBrickList.append(PreviousLookBrick())
            case SetSizeToBrick().xmlTag()?.uppercased():
                let newBrick = SetSizeToBrick()
                newBrick.size = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.size?.category = "SIZE"
                resultBrickList.append(newBrick)
            case ChangeSizeByNBrick().xmlTag()?.uppercased():
                let newBrick = ChangeSizeByNBrick()
                newBrick.size = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.size?.category = "SIZE_CHANGE"
                resultBrickList.append(newBrick)
            case ShowBrick().xmlTag()?.uppercased():
                resultBrickList.append(ShowBrick())
            case HideBrick().xmlTag()?.uppercased():
                resultBrickList.append(HideBrick())
            case SetTransparencyBrick().xmlTag()?.uppercased(), "SETGHOSTEFFECTBRICK":
                let newBrick = SetTransparencyBrick()
                newBrick.transparency = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.transparency?.category = "TRANSPARENCY"
                resultBrickList.append(newBrick)
            case ChangeTransparencyByNBrick().xmlTag()?.uppercased(), "CHANGEGHOSTEFFECTBYNBRICK":
                let newBrick = ChangeTransparencyByNBrick()
                newBrick.changeTransparency = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.changeTransparency?.category = "TRANSPARENCY_CHANGE"
                resultBrickList.append(newBrick)
            case SetBrightnessBrick().xmlTag()?.uppercased():
                let newBrick = SetBrightnessBrick()
                newBrick.brightness = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.brightness?.category = "BRIGHTNESS"
                resultBrickList.append(newBrick)
            case ChangeBrightnessByNBrick().xmlTag()?.uppercased():
                let newBrick = ChangeBrightnessByNBrick()
                newBrick.changeBrightness = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.changeBrightness?.category = "BRIGHTNESS_CHANGE"
                resultBrickList.append(newBrick)
            case SetColorBrick().xmlTag()?.uppercased():
                let newBrick = SetColorBrick()
                newBrick.color = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.color?.category = "COLOR"
                resultBrickList.append(newBrick)
            case ChangeColorByNBrick().xmlTag()?.uppercased():
                let newBrick = ChangeColorByNBrick()
                newBrick.changeColor = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.changeColor?.category = "COLOR_CHANGE"
                resultBrickList.append(newBrick)
            case ClearGraphicEffectBrick().xmlTag()?.uppercased():
                resultBrickList.append(ClearGraphicEffectBrick())
            case FlashBrick().xmlTag()?.uppercased(), "LEDONBRICK", "LEDOFFBRICK":
                var newBrick = FlashBrick()
                if let flashState = brick.spinnerSelectionID {
                    newBrick = FlashBrick(choice: Int32(flashState) ?? 0)
                }
                resultBrickList.append(newBrick)
            case CameraBrick().xmlTag()?.uppercased():
                var newBrick = CameraBrick()
                if let cameraState = brick.spinnerSelectionID {
                    newBrick = CameraBrick(choice: Int32(cameraState) ?? 0)
                }
                resultBrickList.append(newBrick)
            case ChooseCameraBrick().xmlTag()?.uppercased():
                var newBrick = ChooseCameraBrick()
                if let cameraState = brick.spinnerSelectionID {
                    newBrick = ChooseCameraBrick(choice: Int32(cameraState) ?? 0)
                }
                resultBrickList.append(newBrick)
            case ThinkBubbleBrick().xmlTag()?.uppercased():
                let newBrick = ThinkBubbleBrick()
                newBrick.formula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.formula?.category = "STRING"
                resultBrickList.append(newBrick)
            case ThinkForBubbleBrick().xmlTag()?.uppercased():
                let newBrick = ThinkForBubbleBrick()
                newBrick.stringFormula = mapFormulaListToBrick(input: brick)?.lastObject as? Formula
                newBrick.stringFormula?.category = "STRING"
                newBrick.intFormula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.intFormula?.category = "DURATION_IN_SECONDS"
                resultBrickList.append(newBrick)
            // MARK: Sound Bricks
            case PlaySoundBrick().xmlTag()?.uppercased():
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
            case StopAllSoundsBrick().xmlTag()?.uppercased():
                resultBrickList.append(StopAllSoundsBrick())
            case SetVolumeToBrick().xmlTag()?.uppercased():
                let newBrick = SetVolumeToBrick()
                newBrick.volume = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.volume?.category = "VOLUME"
                resultBrickList.append(newBrick)
            case ChangeVolumeByNBrick().xmlTag()?.uppercased():
                let newBrick = ChangeVolumeByNBrick()
                newBrick.volume = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.volume?.category = "VOLUME_CHANGE"
                resultBrickList.append(newBrick)
            case SpeakBrick().xmlTag()?.uppercased():
                let newBrick = SpeakBrick()
                newBrick.formula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.formula?.category = "SPEAK"
                newBrick.text = brick.noteMessage
                resultBrickList.append(newBrick)
            case SpeakAndWaitBrick().xmlTag()?.uppercased():
                let newBrick = SpeakAndWaitBrick()
                newBrick.formula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.formula?.category = "SPEAK"
                newBrick.text = brick.noteMessage
                resultBrickList.append(newBrick)
            // MARK: Variable Bricks
            case SetVariableBrick().xmlTag()?.uppercased():
                let newBrick = SetVariableBrick()
                newBrick.userVariable = resolveUserVariable(project: project, object: object, script: script, brick: brick, isList: false)
                newBrick.uVar = newBrick.userVariable
                newBrick.variableFormula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.variableFormula?.category = "VARIABLE"
                resultBrickList.append(newBrick)
            case ChangeVariableBrick().xmlTag()?.uppercased():
                let newBrick = ChangeVariableBrick()
                newBrick.userVariable = resolveUserVariable(project: project, object: object, script: script, brick: brick, isList: false)
                newBrick.uVar = newBrick.userVariable
                newBrick.variableFormula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.variableFormula?.category = "VARIABLE_CHANGE"
                resultBrickList.append(newBrick)
            case ShowTextBrick().xmlTag()?.uppercased():
                let newBrick = ShowTextBrick()
                newBrick.userVariable = resolveUserVariable(project: project, object: object, script: script, brick: brick, isList: false)
                newBrick.uVar = newBrick.userVariable
                newBrick.xFormula = mapFormulaListToBrick(input: brick)?.lastObject as? Formula
                newBrick.yFormula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.xFormula?.category = "X_POSITION"
                newBrick.yFormula?.category = "Y_POSITION"
                resultBrickList.append(newBrick)
            case HideTextBrick().xmlTag()?.uppercased():
                let newBrick = HideTextBrick()
                newBrick.userVariable = resolveUserVariable(project: project, object: object, script: script, brick: brick, isList: false)
                newBrick.uVar = newBrick.userVariable
                resultBrickList.append(newBrick)
            case AddItemToUserListBrick().xmlTag()?.uppercased():
                let newBrick = AddItemToUserListBrick()
                newBrick.userList = resolveUserVariable(project: project, object: object, script: script, brick: brick, isList: true)
                newBrick.uVar = newBrick.userList
                newBrick.listFormula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.listFormula?.category = "LIST_ADD_ITEM"
                resultBrickList.append(newBrick)
            case DeleteItemOfUserListBrick().xmlTag()?.uppercased():
                let newBrick = DeleteItemOfUserListBrick()
                newBrick.userList = resolveUserVariable(project: project, object: object, script: script, brick: brick, isList: true)
                newBrick.uVar = newBrick.userList
                newBrick.listFormula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.listFormula?.category = "LIST_DELETE_ITEM"
                resultBrickList.append(newBrick)
            case InsertItemIntoUserListBrick().xmlTag()?.uppercased():
                let newBrick = InsertItemIntoUserListBrick()
                newBrick.userList = resolveUserVariable(project: project, object: object, script: script, brick: brick, isList: true)
                newBrick.uVar = newBrick.userList
                newBrick.index = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.index?.category = "INSERT_ITEM_INTO_USERLIST_INDEX"
                newBrick.elementFormula = mapFormulaListToBrick(input: brick)?.lastObject as? Formula
                newBrick.elementFormula?.category = "INSERT_ITEM_INTO_USERLIST_VALUE"
                resultBrickList.append(newBrick)
            case ReplaceItemInUserListBrick().xmlTag()?.uppercased():
                let newBrick = ReplaceItemInUserListBrick()
                newBrick.userList = resolveUserVariable(project: project, object: object, script: script, brick: brick, isList: true)
                newBrick.uVar = newBrick.userList
                newBrick.elementFormula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.elementFormula?.category = "REPLACE_ITEM_IN_USERLIST_VALUE"
                newBrick.index = mapFormulaListToBrick(input: brick)?.lastObject as? Formula
                newBrick.index?.category = "REPLACE_ITEM_IN_USERLIST_INDEX"
                resultBrickList.append(newBrick)
            // MARK: Arduino Bricks
            case ArduinoSendDigitalValueBrick().xmlTag()?.uppercased():
                let newBrick = ArduinoSendDigitalValueBrick()
                newBrick.pin = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.pin?.category = "ARDUINO_DIGITAL_PIN_NUMBER"
                newBrick.value = mapFormulaListToBrick(input: brick)?.lastObject as? Formula
                newBrick.value?.category = "ARDUINO_DIGITAL_PIN_VALUE"
                resultBrickList.append(newBrick)
            case ArduinoSendPWMValueBrick().xmlTag()?.uppercased():
                let newBrick = ArduinoSendPWMValueBrick()
                newBrick.pin = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.pin?.category = "ARDUINO_ANALOG_PIN_NUMBER"
                newBrick.value = mapFormulaListToBrick(input: brick)?.lastObject as? Formula
                newBrick.value?.category = "ARDUINO_ANALOG_PIN_VALUE"
                resultBrickList.append(newBrick)
            // MARK: Alternative Bricks
            case ComeToFrontBrick().xmlTag()?.uppercased():
                resultBrickList.append(ComeToFrontBrick())
            case GoNStepsBackBrick().xmlTag()?.uppercased():
                let newBrick = GoNStepsBackBrick()
                newBrick.steps = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.steps?.category = "STEPS"
                resultBrickList.append(newBrick)
            case SayBubbleBrick().xmlTag()?.uppercased():
                let newBrick = SayBubbleBrick()
                newBrick.formula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                newBrick.formula?.category = "STRING"
                resultBrickList.append(newBrick)
            case SayForBubbleBrick().xmlTag()?.uppercased():
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
            //resultBrickList.last?.commentedOut = brick.commentedOut
        }
        if resultBrickList.isEmpty { return nil }

        return NSMutableArray(array: resultBrickList)
    }
}
