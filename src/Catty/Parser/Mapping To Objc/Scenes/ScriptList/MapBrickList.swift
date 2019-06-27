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

extension CBXMLMapping {

    static func mapBrToScr(inp: CBScript?, scr: Script, obj: SpriteObject, cbo: CBObject, objs: [CBObject], proj: Project, cbp: CBProject?, comp: @escaping (NSMutableArray?, CBXMLError?) -> Void) {
        var brickList = [Brick]()
        guard let input = inp?.brickList?.brick else { comp(nil, .brickMappingError); return }
        guard let lookList = scr.object.lookList else { comp(nil, .brickMappingError); return }
        guard let soundList = scr.object.soundList else { comp(nil, .brickMappingError); return }

        for brick in input {
            switch brick.type?.uppercased() {

                // TODO: goto front brick missing???

            // MARK: - Condition Bricks
            case kBroadcastBrick.uppercased():
                let brick = BroadcastBrick(message: brick.broadcastMessage ?? "")
                brick.script = scr
                brickList.append(brick)
            case kBroadcastWaitBrick.uppercased():
                let brick = BroadcastWaitBrick(message: brick.broadcastMessage ?? "")
                brick.script = scr
                brickList.append(brick)
            case kIfLogicBeginBrick.uppercased():
                let beginBrick = IfLogicBeginBrick()
                beginBrick.script = scr
                beginBrick.ifCondition = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                brickList.append(beginBrick)
            case kIfLogicElseBrick.uppercased():
                let elseBrick = IfLogicElseBrick()
                elseBrick.script = scr
                for item in brickList.reversed() where item.brickType == kBrickType.ifBrick {
                    elseBrick.ifBeginBrick = item as? IfLogicBeginBrick
                    (item as? IfLogicBeginBrick)?.ifElseBrick = elseBrick
                }
                brickList.append(elseBrick)
            case kIfLogicEndBrick.uppercased():
                let endBrick = IfLogicEndBrick()
                endBrick.script = scr
                for item in brickList.reversed() where item.brickType == kBrickType.ifElseBrick {
                    endBrick.ifBeginBrick = (item as? IfLogicElseBrick)?.ifBeginBrick
                    endBrick.ifElseBrick = item as? IfLogicElseBrick
                    (item as? IfLogicElseBrick)?.ifBeginBrick.ifEndBrick = endBrick
                    (item as? IfLogicElseBrick)?.ifEndBrick = endBrick
                }
                brickList.append(endBrick)
            case kIfThenLogicBeginBrick.uppercased():
                let beginBrick = IfThenLogicBeginBrick()
                beginBrick.script = scr
                beginBrick.ifCondition = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                brickList.append(beginBrick)
            case kIfThenLogicEndBrick.uppercased():
                let endBrick = IfThenLogicEndBrick()
                endBrick.script = scr
                for item in brickList.reversed() where item.brickType == kBrickType.ifThenBrick {
                    endBrick.ifBeginBrick = item as? IfThenLogicBeginBrick
                    (item as? IfThenLogicBeginBrick)?.ifEndBrick = endBrick
                }
                brickList.append(endBrick)
            case kForeverBrick.uppercased():
                let brick = ForeverBrick()
                brick.script = scr
                brickList.append(brick)
            case kRepeatBrick.uppercased():
                let repeatUntilBrick = RepeatBrick()
                repeatUntilBrick.script = scr
                repeatUntilBrick.timesToRepeat = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                brickList.append(repeatUntilBrick)
            case kRepeatUntilBrick.uppercased():
                let repeatBrick = RepeatUntilBrick()
                repeatBrick.script = scr
                repeatBrick.repeatCondition = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                brickList.append(repeatBrick)
            case kLoopEndBrick.uppercased(), kLoopEndlessBrick.uppercased():
                let endBrick = LoopEndBrick()
                endBrick.script = scr
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
            case kNoteBrick.uppercased():
                let noteBrick = NoteBrick()
                noteBrick.script = scr
                noteBrick.note = brick.noteMessage
                brickList.append(noteBrick)
            case kWaitBrick.uppercased():
                let waitBrick = WaitBrick()
                waitBrick.script = scr
                if let time = mapFormulaListToBrick(input: brick)?.firstObject as? Formula {
                    waitBrick.timeToWaitInSeconds = time
                }
                brickList.append(waitBrick)
            case kWaitUntilBrick.uppercased():
                let waitBrick = WaitUntilBrick()
                waitBrick.script = scr
                if let condition = mapFormulaListToBrick(input: brick)?.firstObject as? Formula {
                    waitBrick.waitCondition = condition
                }
                brickList.append(waitBrick)

            // MARK: - Motion Bricks
            case kPlaceAtBrick.uppercased():
                let placeBrick = PlaceAtBrick()
                placeBrick.script = scr
                if let x = brick.xPosition, let y = brick.yPosition {
                    placeBrick.xPosition = mapCBFormulaToFormula(input: x)
                    placeBrick.yPosition = mapCBFormulaToFormula(input: y)
                } else {
                    placeBrick.xPosition = mapFormulaListToBrick(input: brick)?.lastObject as? Formula
                    placeBrick.yPosition = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                }
                brickList.append(placeBrick)
            case kChangeXByNBrick.uppercased():
                let changeBrick = ChangeXByNBrick()
                changeBrick.script = scr
                changeBrick.xMovement = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                brickList.append(changeBrick)
            case kChangeYByNBrick.uppercased():
                let changeBrick = ChangeYByNBrick()
                changeBrick.script = scr
                changeBrick.yMovement = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                brickList.append(changeBrick)
            case kSetXBrick.uppercased():
                let setBrick = SetXBrick()
                setBrick.script = scr
                setBrick.xPosition = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                brickList.append(setBrick)
            case kSetYBrick.uppercased():
                let setBrick = SetYBrick()
                setBrick.script = scr
                setBrick.yPosition = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                brickList.append(setBrick)
            case kIfOnEdgeBounceBrick.uppercased():
                let brick = IfOnEdgeBounceBrick()
                brick.script = scr
                brickList.append(brick)
            case kMoveNStepsBrick.uppercased():
                let stepsBrick = MoveNStepsBrick()
                stepsBrick.script = scr
                stepsBrick.steps = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                brickList.append(stepsBrick)
            case kTurnLeftBrick.uppercased():
                let turnBrick = TurnLeftBrick()
                turnBrick.script = scr
                turnBrick.degrees = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                brickList.append(turnBrick)
            case kTurnRightBrick.uppercased():
                let turnBrick = TurnRightBrick()
                turnBrick.script = scr
                turnBrick.degrees = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                brickList.append(turnBrick)
            case kPointInDirectionBrick.uppercased():
                let pointBrick = PointInDirectionBrick()
                pointBrick.script = scr
                pointBrick.degrees = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                brickList.append(pointBrick)
            case kPointToBrick.uppercased():
                let pointBrick = PointToBrick()
                pointBrick.script = scr
                for object in objs where object.name == brick.pointedObject {
                    pointBrick.pointedObject = mapCBObjectToSpriteObject(input: object, objects: objs, project: proj, cbProject: cbp, blankMap: false)
                }
                brickList.append(pointBrick)
            case kGlideToBrick.uppercased():
                let glideBrick = GlideToBrick()
                glideBrick.script = scr
                let formulaTreeMapping = mapFormulaListToBrick(input: brick)
                guard let formulaMapping = formulaTreeMapping else { break }
                glideBrick.durationInSeconds = formulaMapping.firstObject as? Formula
                if formulaMapping.count >= 3 {
                    glideBrick.xDestination = formulaMapping[1] as? Formula
                    glideBrick.yDestination = formulaMapping[2] as? Formula
                } else {
                    glideBrick.xDestination = mapGlideDestinations(input: brick, xDestination: true)?.firstObject as? Formula
                    glideBrick.yDestination = mapGlideDestinations(input: brick, xDestination: false)?.firstObject as? Formula
                }
                brickList.append(glideBrick)
            case kVibrationBrick.uppercased():
                let vibrationBrick = VibrationBrick()
                vibrationBrick.script = scr
                vibrationBrick.durationInSeconds = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                brickList.append(vibrationBrick)

            // MARK: - Look Bricks
            case kSetBackgroundBrick.uppercased():
                let backgroundBrick = SetBackgroundBrick()
                backgroundBrick.script = scr
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
            case kSetLookBrick.uppercased():
                let setLookBrick = SetLookBrick()
                setLookBrick.script = scr
                let tmpSpriteObj = SpriteObject()
                tmpSpriteObj.lookList = lookList
                setLookBrick.setDefaultValuesFor(tmpSpriteObj)
                if let range = brick.lookReference?.range(of: "[(0-9)*]", options: .regularExpression) {
                    let index = String(brick.lookReference?[range] ?? "")
                    if let index = Int(index), index <= lookList.count, index > 0 {
                        setLookBrick.look = lookList[index - 1] as? Look
                    }
                }
                brickList.append(setLookBrick)
            case kNextLookBrick.uppercased():
                let nextLookBrick = NextLookBrick()
                nextLookBrick.script = scr
                brickList.append(nextLookBrick)
            case kPreviousLookBrick.uppercased():
                let previousLookBrick = PreviousLookBrick()
                previousLookBrick.script = scr
                brickList.append(previousLookBrick)
            case kSetSizeToBrick.uppercased():
                let setSizeBrick = SetSizeToBrick()
                setSizeBrick.script = scr
                setSizeBrick.size = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                brickList.append(setSizeBrick)
            case kChangeSizeByNBrick.uppercased():
                let changeSizeBrick = ChangeSizeByNBrick()
                changeSizeBrick.script = scr
                changeSizeBrick.size = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                brickList.append(changeSizeBrick)
            case kShowBrick.uppercased():
                let brick = ShowBrick()
                brick.script = scr
                brickList.append(brick)
            case kHideBrick.uppercased():
                let brick = HideBrick()
                brick.script = scr
                brickList.append(brick)
            case kSetTransparencyBrick.uppercased():
                let transparencyBrick = SetTransparencyBrick()
                transparencyBrick.script = scr
                transparencyBrick.transparency = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                brickList.append(transparencyBrick)
            case kChangeTransparencyByNBrick.uppercased():
                let transparencyBrick = ChangeTransparencyByNBrick()
                transparencyBrick.script = scr
                transparencyBrick.changeTransparency = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                brickList.append(transparencyBrick)
            case kSetBrightnessBrick.uppercased():
                let brightnessBrick = SetBrightnessBrick()
                brightnessBrick.script = scr
                brightnessBrick.brightness = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                brickList.append(brightnessBrick)
            case kChangeBrightnessByNBrick.uppercased():
                let brightnessBrick = ChangeBrightnessByNBrick()
                brightnessBrick.script = scr
                brightnessBrick.changeBrightness = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                brickList.append(brightnessBrick)
            case kSetColorBrick.uppercased():
                let colorBrick = SetColorBrick()
                colorBrick.script = scr
                colorBrick.color = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                brickList.append(colorBrick)
            case kChangeColorByNBrick.uppercased():
                let colorBrick = ChangeColorByNBrick()
                colorBrick.script = scr
                colorBrick.changeColor = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                brickList.append(colorBrick)
            case kClearGraphicEffectBrick.uppercased():
                let clearGraphicBrick = ClearGraphicEffectBrick()
                clearGraphicBrick.script = scr
                brickList.append(clearGraphicBrick)
            case kFlashBrick.uppercased():
                var flashBrick = FlashBrick()
                if let flashState = brick.spinnerSelectionID {
                    flashBrick = FlashBrick(choice: Int32(flashState) ?? 0)
                }
                flashBrick.script = scr
                brickList.append(flashBrick)
            case kCameraBrick.uppercased():
                var cameraBrick = CameraBrick()
                if let cameraState = brick.spinnerSelectionID {
                    cameraBrick = CameraBrick(choice: Int32(cameraState) ?? 0)
                }
                cameraBrick.script = scr
                brickList.append(cameraBrick)
            case kChooseCameraBrick.uppercased():
                var cameraBrick = ChooseCameraBrick()
                if let cameraState = brick.spinnerSelectionID {
                    cameraBrick = ChooseCameraBrick(choice: Int32(cameraState) ?? 0)
                }
                cameraBrick.script = scr
                brickList.append(cameraBrick)

            // MARK: - Sound Bricks
            case kPlaySoundBrick.uppercased():
                let soundBrick = PlaySoundBrick()
                soundBrick.script = scr
                for sound in soundList {
                    if let sound = sound as? Sound, sound.name == brick.sound?.name {
                        soundBrick.sound = sound
                        break
                    }
                }
                if let range = brick.sound?.reference?.range(of: "[(0-9)*]", options: .regularExpression) {
                    let index = String(brick.sound?.reference?[range] ?? "")
                    if let index = Int(index), index <= soundList.count, index > 0 {
                        soundBrick.sound = soundList[index] as? Sound
                    }
                } else {
                    soundBrick.sound = soundList.firstObject as? Sound
                }
                brickList.append(soundBrick)
            case kStopAllSoundsBrick.uppercased():
                let brick = StopAllSoundsBrick()
                brick.script = scr
                brickList.append(brick)
            case kSetVolumeToBrick.uppercased():
                let setVolumeBrick = SetVolumeToBrick()
                setVolumeBrick.script = scr
                setVolumeBrick.volume = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                brickList.append(setVolumeBrick)
            case kChangeVolumeByNBrick.uppercased():
                let changeVolumeBrick = ChangeVolumeByNBrick()
                changeVolumeBrick.script = scr
                changeVolumeBrick.volume = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                brickList.append(changeVolumeBrick)
            case kSpeakBrick.uppercased():
                let speakBrick = SpeakBrick()
                speakBrick.script = scr
                speakBrick.formula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                speakBrick.text = brick.noteMessage
                brickList.append(speakBrick)
            case kSpeakAndWaitBrick.uppercased():
                let speakWaitBrick = SpeakAndWaitBrick()
                speakWaitBrick.script = scr
                speakWaitBrick.formula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                speakWaitBrick.text = brick.noteMessage
                brickList.append(speakWaitBrick)
                // TODO: the two bricks above!!!

            // MARK: - Variable Bricks
            case kSetVariableBrick.uppercased():
                let variableBrick = SetVariableBrick()
                variableBrick.userVariable = getUserVariableFor(brick: brick, object: cbo, script: inp, project: proj, cbProject: cbp)
                variableBrick.variableFormula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                updateVariableContainerWith(newBrick: variableBrick, project: proj)
                variableBrick.script = scr
                brickList.append(variableBrick)
            case kChangeVariableBrick.uppercased():
                let variableBrick = ChangeVariableBrick()
                variableBrick.userVariable = getUserVariableFor(brick: brick, object: cbo, script: inp, project: proj, cbProject: cbp)
                variableBrick.variableFormula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                updateVariableContainerWith(newBrick: variableBrick, project: proj)
                variableBrick.script = scr
                brickList.append(variableBrick)
            case kShowTextBrick.uppercased():
                let showBrick = ShowTextBrick()
                showBrick.xFormula = mapFormulaListToBrick(input: brick)?.lastObject as? Formula
                showBrick.yFormula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                showBrick.userVariable = getUserVariableFor(brick: brick, object: cbo, script: inp, project: proj, cbProject: cbp)
                updateVariableContainerWith(newBrick: showBrick, project: proj)
                showBrick.script = scr
                brickList.append(showBrick)
            case kHideTextBrick.uppercased():
                let hideBrick = HideTextBrick()
                hideBrick.userVariable = getUserVariableFor(brick: brick, object: cbo, script: inp, project: proj, cbProject: cbp)
                updateVariableContainerWith(newBrick: hideBrick, project: proj)
                hideBrick.script = scr
                brickList.append(hideBrick)
            case kAddItemToUserListBrick.uppercased():
                let listBrick = AddItemToUserListBrick()
                listBrick.listFormula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                listBrick.userList = getUserVariableFor(brick: brick, object: cbo, script: inp, project: proj, cbProject: cbp)
                updateVariableContainerWith(newBrick: listBrick, project: proj)
                listBrick.script = scr
                brickList.append(listBrick)
            case kDeleteItemOfUserListBrick.uppercased():
                let listBrick = DeleteItemOfUserListBrick()
                listBrick.userList = getUserVariableFor(brick: brick, object: cbo, script: inp, project: proj, cbProject: cbp)
                listBrick.listFormula = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                updateVariableContainerWith(newBrick: listBrick, project: proj)
                listBrick.script = scr
                brickList.append(listBrick)
            case kInsertItemIntoUserListBrick.uppercased():
                let listBrick = InsertItemIntoUserListBrick()
                listBrick.userList = getUserVariableFor(brick: brick, object: cbo, script: inp, project: proj, cbProject: cbp)
                listBrick.index = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                listBrick.elementFormula = mapFormulaListToBrick(input: brick)?.lastObject as? Formula
                updateVariableContainerWith(newBrick: listBrick, project: proj)
                listBrick.script = scr
                brickList.append(listBrick)
            case kReplaceItemInUserListBrick.uppercased():
                let listBrick = ReplaceItemInUserListBrick()
                listBrick.userList = getUserVariableFor(brick: brick, object: cbo, script: inp, project: proj, cbProject: cbp)
                listBrick.elementFormula = mapFormulaListToBrick(input: brick)?.lastObject as? Formula
                listBrick.index = mapFormulaListToBrick(input: brick)?.firstObject as? Formula
                updateVariableContainerWith(newBrick: listBrick, project: proj)
                listBrick.script = scr
                brickList.append(listBrick)
            default:
                comp(nil, .unsupportedBrick)
            }
        }
        comp(NSMutableArray(array: brickList), nil)
    }

    static func updateBrick(from: Brick, to: Brick) {
        switch from.brickType {
        case kBrickType.setVariableBrick:
            if let from = from as? SetVariableBrick, let to = to as? SetVariableBrick {
                to.userVariable = from.userVariable
            }
        case kBrickType.changeVariableBrick:
            if let from = from as? ChangeVariableBrick, let to = to as? ChangeVariableBrick {
                to.userVariable = from.userVariable
            }
        case kBrickType.showTextBrick:
            if let from = from as? ShowTextBrick, let to = to as? ShowTextBrick {
                to.userVariable = from.userVariable
            }
        case kBrickType.hideTextBrick:
            if let from = from as? HideTextBrick, let to = to as? HideTextBrick {
                to.userVariable = from.userVariable
            }
        case kBrickType.addItemToUserListBrick:
            if let from = from as? AddItemToUserListBrick, let to = to as? AddItemToUserListBrick {
                to.userList = from.userList
            }
        case kBrickType.deleteItemOfUserListBrick:
            if let from = from as? DeleteItemOfUserListBrick, let to = to as? DeleteItemOfUserListBrick {
                to.userList = from.userList
            }
        case kBrickType.insertItemIntoUserListBrick:
            if let from = from as? InsertItemIntoUserListBrick, let to = to as? InsertItemIntoUserListBrick {
                to.userList = from.userList
            }
        case kBrickType.replaceItemInUserListBrick:
            if let from = from as? ReplaceItemInUserListBrick, let to = to as? ReplaceItemInUserListBrick {
                to.userList = from.userList
            }
        default:
            return
        }
    }

    static func updateVariableContainerWith(newBrick: Brick, project: Project) {
        for oIdx in 0..<project.variables.objectListOfLists.count() {
            let object = project.variables.objectListOfLists.key(at: oIdx) as? SpriteObject
            if let scriptList = object?.scriptList {
                for script in scriptList {
                    if let script = script as? Script {
                        for brick in script.brickList {
                            if let brick = brick as? Brick {
                                updateBrick(from: newBrick, to: brick)
                            }
                        }
                    }
                }
            }
        }
        for oIdx in 0..<project.variables.objectVariableList.count() {
            let object = project.variables.objectVariableList.key(at: oIdx) as? SpriteObject
            if let scriptList = object?.scriptList {
                for script in scriptList {
                    if let script = script as? Script {
                        for brick in script.brickList {
                            if let brick = brick as? Brick {
                                updateBrick(from: newBrick, to: brick)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - UserVariables for Bricks
    static func getUserVariableFor(brick: CBBrick, object: CBObject, script: CBScript?, project: Project, cbProject: CBProject?) -> UserVariable? {
        guard let script = script else { return nil }
        var userVar = getUserVarForBrickOrIndex(brick: brick, project: project, index: nil)

        if userVar == nil, let ref = brick.userVariableReference, ref.isEmpty == false {
            var res: UserVariable?

            if let uVar = brick.userVariable, uVar.isEmpty == false {
                res = getUserVarForBrickOrIndex(brick: brick, project: project, index: 0)
            } else if let uList = brick.userList, uList.isEmpty == false {
                res = getUserVarForBrickOrIndex(brick: brick, project: project, index: 0)
            } else {
                let brick: CBBrick?
                if ref.split(separator: "/").count < 6 {
                    let extr = extractAbstractNumbersFrom(object: object, reference: ref, project: cbProject)
                    brick = script.brickList?.brick?[extr.1]
                } else if ref.split(separator: "/").count < 9 {
                    let extr = extractAbstractNumbersFrom(object: object, reference: ref, project: cbProject)
                    brick = object.scriptList?.script?[extr.0].brickList?.brick?[extr.1]
                } else {
                    let extr = extractAbstractNumbersFrom(reference: ref, project: cbProject)
                    brick = cbProject?.scenes?.first?.objectList?.object?[extr.0].scriptList?.script?[extr.1].brickList?.brick?[extr.2]
                }
                if let br = brick {
                    res = getUserVarForBrickOrIndex(brick: br, project: project, index: 0)
                }
            }
            userVar = res
        }

        return userVar
    }

    static func getUserVarForBrickOrIndex(brick: CBBrick, project: Project, index: Int?) -> UserVariable? {
        var returnVariable: UserVariable?

        if project.variables.programVariableList.count >= 1 {
            for variable in project.variables.programVariableList {
                if let uVar = variable as? UserVariable {
                    if uVar.name == brick.userVariable {
                        returnVariable = uVar
                    }
                }
            }
        }
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
            for index in 0..<project.variables.objectVariableList.count() {
                if let objectVariableList = project.variables.objectVariableList.object(at: index) as? NSArray, objectVariableList.count >= 1 {

                    if let uVar = brick.userVariable, uVar.isEmpty == false {
                        returnVariable = getUserVariableOrUserListFrom(list: objectVariableList, brick: brick)
                    } else {
                        returnVariable = getUserVariableOrUserListFrom(list: objectVariableList, atIndex: Int(index))
                    }
                }
            }
        }

        return returnVariable
    }

    static func getUserVariableOrUserListFrom(list: NSArray, atIndex: Int) -> UserVariable? {
        let atIndex = atIndex - 2 // because reference is one higher and array starts ar 0
        guard list.count >= atIndex && atIndex >= 0 else { return nil }

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
