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

extension CBXMLMapping {

    static func mapBrickListToScript(input: CBScript?, script: Script, lookList: NSMutableArray, soundList: NSMutableArray, objects: [CBObject], project: Project) -> NSMutableArray {
        var brickList = [Brick]()
        guard let input = input?.brickList?.brick else { return  NSMutableArray(array: brickList) }

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
                    } else if item.brickType == kBrickType.repeatUntilBrick {
                        (item as? RepeatUntilBrick)?.loopEndBrick = endBrick
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
                } else if soundList.count == 1 {
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

            default:
                print("ERROR: mapping BrickList to Script")
            }
        }
        return NSMutableArray(array: brickList)
    }
}
