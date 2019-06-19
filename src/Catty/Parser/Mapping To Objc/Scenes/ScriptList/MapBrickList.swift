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

extension CBXMLMapping {

    static func mapBrickListToScript(input: CBScript?, script: Script, obj: SpriteObject, objects: [CBObject], project: Project, completion: @escaping (NSMutableArray?, CBXMLMappingError?) -> Void) {
        var brickList = [Brick]()
        guard let input = input?.brickList?.brick else { completion(nil, .brickMappingError); return }
        guard let lookList = script.object.lookList else { completion(nil, .brickMappingError); return }
        guard let soundList = script.object.soundList else { completion(nil, .brickMappingError); return }

        for brick in input {
            switch brick.type {

            // MARK: - Condition Bricks
            case kBroadcastBrick:
                let brick = BroadcastBrick(message: brick.broadcastMessage ?? "")
                brick.script = script
                brickList.append(brick)
            case kBroadcastWaitBrick:
                let brick = BroadcastWaitBrick(message: brick.broadcastMessage ?? "")
                brick.script = script
                brickList.append(brick)
            case kIfLogicBeginBrick:
                let beginBrick = IfLogicBeginBrick()
                beginBrick.script = script
                beginBrick.ifCondition = mapFormulaListToBrick(input: brick).firstObject as? Formula
                brickList.append(beginBrick)
            case kIfLogicElseBrick:
                let elseBrick = IfLogicElseBrick()
                elseBrick.script = script
                for item in brickList.reversed() where item.brickType == kBrickType.ifBrick {
                    elseBrick.ifBeginBrick = item as? IfLogicBeginBrick
                    (item as? IfLogicBeginBrick)?.ifElseBrick = elseBrick
                }
                brickList.append(elseBrick)
            case kIfLogicEndBrick:
                let endBrick = IfLogicEndBrick()
                endBrick.script = script
                for item in brickList.reversed() where item.brickType == kBrickType.ifElseBrick {
                    endBrick.ifBeginBrick = (item as? IfLogicElseBrick)?.ifBeginBrick
                    endBrick.ifElseBrick = item as? IfLogicElseBrick
                    (item as? IfLogicElseBrick)?.ifBeginBrick.ifEndBrick = endBrick
                    (item as? IfLogicElseBrick)?.ifEndBrick = endBrick
                }
                brickList.append(endBrick)
            case kIfThenLogicBeginBrick:
                let beginBrick = IfThenLogicBeginBrick()
                beginBrick.script = script
                beginBrick.ifCondition = mapFormulaListToBrick(input: brick).firstObject as? Formula
                brickList.append(beginBrick)
            case kIfThenLogicEndBrick:
                let endBrick = IfThenLogicEndBrick()
                endBrick.script = script
                for item in brickList.reversed() where item.brickType == kBrickType.ifThenBrick {
                    endBrick.ifBeginBrick = item as? IfThenLogicBeginBrick
                    (item as? IfThenLogicBeginBrick)?.ifEndBrick = endBrick
                }
                brickList.append(endBrick)
            case kForeverBrick:
                let brick = ForeverBrick()
                brick.script = script
                brickList.append(brick)
            case kRepeatBrick:
                let repeatBrick = RepeatUntilBrick()
                repeatBrick.script = script
                repeatBrick.repeatCondition = mapFormulaListToBrick(input: brick).firstObject as? Formula
                brickList.append(repeatBrick)
            case kRepeatUntilBrick:
                let repeatUntilBrick = RepeatBrick()
                repeatUntilBrick.script = script
                repeatUntilBrick.timesToRepeat = mapFormulaListToBrick(input: brick).firstObject as? Formula
                brickList.append(repeatUntilBrick)
            case kLoopEndBrick, kLoopEndlessBrick:
                let endBrick = LoopEndBrick()
                endBrick.script = script
                for item in brickList.reversed() {
                    endBrick.loopBeginBrick = item as? LoopBeginBrick

                    if item.brickType == kBrickType.repeatBrick {
                        (item as? RepeatBrick)?.loopEndBrick = endBrick
                        break
                    } else if item.brickType == kBrickType.repeatUntilBrick {
                        (item as? RepeatUntilBrick)?.loopEndBrick = endBrick
                        break
                    } else if item.brickType == kBrickType.foreverBrick {
                        (item as? ForeverBrick)?.loopEndBrick = endBrick
                        break
                    }
                }
                brickList.append(endBrick)
            case kNoteBrick:
                let noteBrick = NoteBrick()
                noteBrick.script = script
                noteBrick.note = brick.noteMessage
                brickList.append(noteBrick)
            case kWaitBrick:
                let waitBrick = WaitBrick()
                waitBrick.script = script
                if let time = mapFormulaListToBrick(input: brick).firstObject as? Formula {
                    waitBrick.timeToWaitInSeconds = time
                }
                brickList.append(waitBrick)
            case kWaitUntilBrick:
                let waitBrick = WaitUntilBrick()
                waitBrick.script = script
                if let condition = mapFormulaListToBrick(input: brick).firstObject as? Formula {
                    waitBrick.waitCondition = condition
                }
                brickList.append(waitBrick)

            // MARK: - Motion Bricks
            case kPlaceAtBrick:
                let placeBrick = PlaceAtBrick()
                placeBrick.script = script
                placeBrick.xPosition = mapFormulaListToBrick(input: brick).lastObject as? Formula
                placeBrick.yPosition = mapFormulaListToBrick(input: brick).firstObject as? Formula
                brickList.append(placeBrick)
            case kChangeXByNBrick:
                let changeBrick = ChangeXByNBrick()
                changeBrick.script = script
                changeBrick.xMovement = mapFormulaListToBrick(input: brick).firstObject as? Formula
                brickList.append(changeBrick)
            case kChangeYByNBrick:
                let changeBrick = ChangeYByNBrick()
                changeBrick.script = script
                changeBrick.yMovement = mapFormulaListToBrick(input: brick).firstObject as? Formula
                brickList.append(changeBrick)
            case kSetXBrick:
                let setBrick = SetXBrick()
                setBrick.script = script
                setBrick.xPosition = mapFormulaListToBrick(input: brick).firstObject as? Formula
                brickList.append(setBrick)
            case kSetYBrick:
                let setBrick = SetYBrick()
                setBrick.script = script
                setBrick.yPosition = mapFormulaListToBrick(input: brick).firstObject as? Formula
                brickList.append(setBrick)
            case kIfOnEdgeBounceBrick:
                let brick = IfOnEdgeBounceBrick()
                brick.script = script
                brickList.append(brick)
            case kMoveNStepsBrick:
                let stepsBrick = MoveNStepsBrick()
                stepsBrick.script = script
                stepsBrick.steps = mapFormulaListToBrick(input: brick).firstObject as? Formula
                brickList.append(stepsBrick)
            case kTurnLeftBrick:
                let turnBrick = TurnLeftBrick()
                turnBrick.script = script
                turnBrick.degrees = mapFormulaListToBrick(input: brick).firstObject as? Formula
                brickList.append(turnBrick)
            case kTurnRightBrick:
                let turnBrick = TurnRightBrick()
                turnBrick.script = script
                turnBrick.degrees = mapFormulaListToBrick(input: brick).firstObject as? Formula
                brickList.append(turnBrick)
            case kPointInDirectionBrick:
                let pointBrick = PointInDirectionBrick()
                pointBrick.script = script
                pointBrick.degrees = mapFormulaListToBrick(input: brick).firstObject as? Formula
                brickList.append(pointBrick)
            case kPointToBrick:
                let pointBrick = PointToBrick()
                pointBrick.script = script
                for object in objects where object.name == brick.pointedObject {
                    pointBrick.pointedObject = mapCBObjectToSpriteObject(input: object, objects: objects, project: project)
                }
                brickList.append(pointBrick)
            case kGlideToBrick:
                let glideBrick = GlideToBrick()
                glideBrick.script = script
                let mapping = mapFormulaListToBrick(input: brick)
                if mapping.count > 2 {
                    glideBrick.durationInSeconds = mapping[0] as? Formula
                    glideBrick.yDestination = mapping[1] as? Formula
                    glideBrick.xDestination = mapping[2] as? Formula
                }
                brickList.append(glideBrick)
            case kVibrationBrick:
                let vibrationBrick = VibrationBrick()
                vibrationBrick.script = script
                vibrationBrick.durationInSeconds = mapFormulaListToBrick(input: brick).firstObject as? Formula
                brickList.append(vibrationBrick)

            // MARK: - Look Bricks
            case kSetBackgroundBrick:
                let backgroundBrick = SetBackgroundBrick()
                backgroundBrick.script = script
                let tmpSpriteObj = SpriteObject()
                tmpSpriteObj.lookList = lookList
                backgroundBrick.setDefaultValuesFor(tmpSpriteObj)
                if let range = brick.lookReference?.range(of: "[(0-9)*]", options: .regularExpression) {
                    let index = String(brick.lookReference?[range] ?? "")
                    if let index = Int(index), index <= lookList.count, index > 0 {
                        backgroundBrick.look = lookList[index - 1] as? Look
                    }
                }
                brickList.append(backgroundBrick)
            case kNextLookBrick:
                let nextLookBrick = NextLookBrick()
                nextLookBrick.script = script
                brickList.append(nextLookBrick)
            case kPreviousLookBrick:
                let previousLookBrick = PreviousLookBrick()
                previousLookBrick.script = script
                brickList.append(previousLookBrick)
            case kSetSizeToBrick:
                let setSizeBrick = SetSizeToBrick()
                setSizeBrick.script = script
                setSizeBrick.size = mapFormulaListToBrick(input: brick).firstObject as? Formula
                brickList.append(setSizeBrick)
            case kChangeSizeByNBrick:
                let changeSizeBrick = ChangeSizeByNBrick()
                changeSizeBrick.script = script
                changeSizeBrick.size = mapFormulaListToBrick(input: brick).firstObject as? Formula
                brickList.append(changeSizeBrick)
            case kShowBrick:
                let brick = ShowBrick()
                brick.script = script
                brickList.append(brick)
            case kHideBrick:
                let brick = HideBrick()
                brick.script = script
                brickList.append(brick)
            case kSetTransparencyBrick:
                let transparencyBrick = SetTransparencyBrick()
                transparencyBrick.script = script
                transparencyBrick.transparency = mapFormulaListToBrick(input: brick).firstObject as? Formula
                brickList.append(transparencyBrick)
            case kChangeTransparencyByNBrick:
                let transparencyBrick = ChangeTransparencyByNBrick()
                transparencyBrick.script = script
                transparencyBrick.changeTransparency = mapFormulaListToBrick(input: brick).firstObject as? Formula
                brickList.append(transparencyBrick)
            case kSetBrightnessBrick:
                let brightnessBrick = SetBrightnessBrick()
                brightnessBrick.script = script
                brightnessBrick.brightness = mapFormulaListToBrick(input: brick).firstObject as? Formula
                brickList.append(brightnessBrick)
            case kChangeBrightnessByNBrick:
                let brightnessBrick = ChangeBrightnessByNBrick()
                brightnessBrick.script = script
                brightnessBrick.changeBrightness = mapFormulaListToBrick(input: brick).firstObject as? Formula
                brickList.append(brightnessBrick)
            case kSetColorBrick:
                let colorBrick = SetColorBrick()
                colorBrick.script = script
                colorBrick.color = mapFormulaListToBrick(input: brick).firstObject as? Formula
                brickList.append(colorBrick)
            case kChangeColorByNBrick:
                let colorBrick = ChangeColorByNBrick()
                colorBrick.script = script
                colorBrick.changeColor = mapFormulaListToBrick(input: brick).firstObject as? Formula
                brickList.append(colorBrick)
            case kClearGraphicEffectBrick:
                let clearGraphicBrick = ClearGraphicEffectBrick()
                clearGraphicBrick.script = script
                brickList.append(clearGraphicBrick)
            case kFlashBrick:
                var flashBrick = FlashBrick()
                if let flashState = brick.spinnerSelectionID {
                    flashBrick = FlashBrick(choice: Int32(flashState) ?? 0)
                }
                flashBrick.script = script
                brickList.append(flashBrick)
            case kCameraBrick:
                var cameraBrick = CameraBrick()
                if let cameraState = brick.spinnerSelectionID {
                    cameraBrick = CameraBrick(choice: Int32(cameraState) ?? 0)
                }
                cameraBrick.script = script
                brickList.append(cameraBrick)
            case kChooseCameraBrick:
                var cameraBrick = ChooseCameraBrick()
                if let cameraState = brick.spinnerSelectionID {
                    cameraBrick = ChooseCameraBrick(choice: Int32(cameraState) ?? 0)
                }
                cameraBrick.script = script
                brickList.append(cameraBrick)

            // MARK: - Sound Bricks
            case kPlaySoundBrick:
                let soundBrick = PlaySoundBrick()
                soundBrick.script = script
                if let range = brick.sound?.range(of: "[(0-9)*]", options: .regularExpression) {
                    let index = String(brick.sound?[range] ?? "")
                    if let index = Int(index), index <= soundList.count, index > 0 {
                        soundBrick.sound = soundList[index - 1] as? Sound
                    }
                } else if soundList.count >= 1 {
                    soundBrick.sound = soundList[0] as? Sound
                }
                brickList.append(soundBrick)
            case kStopAllSoundsBrick:
                let brick = StopAllSoundsBrick()
                brick.script = script
                brickList.append(brick)
            case kSetVolumeToBrick:
                let setVolumeBrick = SetVolumeToBrick()
                setVolumeBrick.script = script
                setVolumeBrick.volume = mapFormulaListToBrick(input: brick).firstObject as? Formula
                brickList.append(setVolumeBrick)
            case kChangeVolumeByNBrick:
                let changeVolumeBrick = ChangeVolumeByNBrick()
                changeVolumeBrick.script = script
                changeVolumeBrick.volume = mapFormulaListToBrick(input: brick).firstObject as? Formula
                brickList.append(changeVolumeBrick)
            case kSpeakBrick:
                let speakBrick = SpeakBrick()
                speakBrick.script = script
                speakBrick.formula = mapFormulaListToBrick(input: brick).firstObject as? Formula
                speakBrick.text = brick.noteMessage
                brickList.append(speakBrick)
            case kSpeakAndWaitBrick:
                let speakWaitBrick = SpeakAndWaitBrick()
                speakWaitBrick.script = script
                speakWaitBrick.formula = mapFormulaListToBrick(input: brick).firstObject as? Formula
                speakWaitBrick.text = brick.noteMessage
                brickList.append(speakWaitBrick)

            // MARK: - Variable Bricks
            case kSetVariableBrick:
                let variableBrick = SetVariableBrick()
                variableBrick.userVariable = getUserVariableFor(brick: brick, project: project)
                variableBrick.variableFormula = mapFormulaListToBrick(input: brick).firstObject as? Formula
                variableBrick.script = script
                brickList.append(variableBrick)
            case kChangeVariableBrick:
                let variableBrick = ChangeVariableBrick()
                variableBrick.userVariable = getUserVariableFor(brick: brick, project: project)
                variableBrick.variableFormula = mapFormulaListToBrick(input: brick).firstObject as? Formula
                variableBrick.script = script
                brickList.append(variableBrick)
            case kShowTextBrick:
                let showBrick = ShowTextBrick()
                showBrick.xFormula = mapFormulaListToBrick(input: brick).lastObject as? Formula
                showBrick.yFormula = mapFormulaListToBrick(input: brick).firstObject as? Formula
                showBrick.userVariable = getUserVariableFor(brick: brick, project: project)
                showBrick.script = script
                brickList.append(showBrick)
            case kHideTextBrick:
                let hideBrick = HideTextBrick()
                hideBrick.userVariable = getUserVariableFor(brick: brick, project: project)
                hideBrick.script = script
                brickList.append(hideBrick)
            case kAddItemToUserListBrick:
                let listBrick = AddItemToUserListBrick()
                listBrick.listFormula = mapFormulaListToBrick(input: brick).firstObject as? Formula
                listBrick.userList = getUserVariableFor(brick: brick, project: project)
                listBrick.script = script
                brickList.append(listBrick)
            case kDeleteItemOfUserListBrick:
                let listBrick = DeleteItemOfUserListBrick()
                listBrick.script = script
                listBrick.userList = getUserVariableFor(brick: brick, project: project)
                listBrick.listFormula = mapFormulaListToBrick(input: brick).firstObject as? Formula
                brickList.append(listBrick)
            case kInsertItemIntoUserListBrick:
                let listBrick = InsertItemIntoUserListBrick()
                listBrick.script = script
                listBrick.userList = getUserVariableFor(brick: brick, project: project)
                listBrick.index = mapFormulaListToBrick(input: brick).firstObject as? Formula
                listBrick.elementFormula = mapFormulaListToBrick(input: brick).lastObject as? Formula
                brickList.append(listBrick)
            case kReplaceItemInUserListBrick:
                let listBrick = ReplaceItemInUserListBrick()
                listBrick.script = script
                listBrick.userList = getUserVariableFor(brick: brick, project: project)
                listBrick.elementFormula = mapFormulaListToBrick(input: brick).lastObject as? Formula
                listBrick.index = mapFormulaListToBrick(input: brick).firstObject as? Formula
                brickList.append(listBrick)
            default:
                completion(nil, .unsupportedBrick)
            }
        }
        completion(NSMutableArray(array: brickList), nil)
    }

    // MARK: - UserVariables for Bricks
    static func getUserVariableFor(brick: CBBrick, project: Project) -> UserVariable? {
        let userVar = getUserVarForBrickOrIndex(brick: brick, project: project, index: nil)

        if userVar == nil, let ref = brick.userVariableReference, ref.isEmpty == false {
            var res: UserVariable?

            if let range = brick.userVariableReference?.range(of: "[(0-9)*]", options: .regularExpression) {
                let index = String(brick.userVariableReference?[range] ?? "")
                if let index = Int(index) {
                    let res = getUserVarForBrickOrIndex(brick: brick, project: project, index: index)
                    if res != nil {
                        return res
                    }
                }
            }
            if let uVar = brick.userVariable, uVar.isEmpty == false {
                res = getUserVarForBrickOrIndex(brick: brick, project: project, index: 0)
            } else if let uList = brick.userList, uList.isEmpty == false {
                res = getUserVarForBrickOrIndex(brick: brick, project: project, index: 0)
            }
            if res != nil {
                return res
            }
        }

        return userVar
    }

    static func getUserVarForBrickOrIndex(brick: CBBrick, project: Project, index: Int?) -> UserVariable? {
        var returnVariable: UserVariable?

        if project.variables.objectListOfLists.count() >= 1 {
            if let objectListOfLists = project.variables.objectListOfLists.object(at: 0) as? NSArray, objectListOfLists.count >= 1 {
                if let brList = brick.userList, brList.isEmpty == false {
                    returnVariable = getUserVariableOrUserListFrom(list: objectListOfLists, brick: brick)
                } else if let index = index {
                    returnVariable = getUserVariableOrUserListFrom(list: objectListOfLists, atIndex: index)
                }
            }
        }
        if project.variables.objectVariableList.count() >= 1 && returnVariable == nil {
            if let objectVariableList = project.variables.objectVariableList.object(at: 0) as? NSArray, objectVariableList.count >= 1 {

                if let uVar = brick.userVariable, uVar.isEmpty == false {
                    returnVariable = getUserVariableOrUserListFrom(list: objectVariableList, brick: brick)
                } else if let index = index {
                    returnVariable = getUserVariableOrUserListFrom(list: objectVariableList, atIndex: index)
                }
            }
        }

        return returnVariable
    }

    static func getUserVariableOrUserListFrom(list: NSArray, atIndex: Int) -> UserVariable? {
        let atIndex = atIndex - 2 // because reference is one higher and array starts ar 0
        guard list.count >= atIndex else { return nil }

        if let entry = list[atIndex] as? UserVariable {
            return entry
        }

        return nil
    }

    static func getUserVariableOrUserListFrom(list: NSArray, brick: CBBrick) -> UserVariable? {
        guard list.count >= 1 else { return nil }

        for i in 0..<list.count {
            if let entry = list[i] as? UserVariable, entry.name == brick.userVariable ?? brick.userList {
                if let uVar = list[i] as? UserVariable {
                    return uVar
                }
            }
        }

        return nil
    }
}
