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

extension CBXMLMapping {

    static func mapBrickListToScript(input: CBScript?, objects: [CBObject]) -> NSMutableArray {
        var brickList = [Brick]()
        guard let input = input?.brickList?.brick else { return  NSMutableArray(array: brickList) }

        for brick in input {
            switch brick.type {

            // MARK: - Condition Bricks
            case kBroadcastBrick:
                brickList.append(BroadcastBrick(message: brick.broadcastMessage ?? ""))
            case kBroadcastWaitBrick:
                brickList.append(BroadcastWaitBrick(message: brick.broadcastMessage ?? ""))
            case kIfLogicBeginBrick:
                let beginBrick = IfLogicBeginBrick()
                beginBrick.ifCondition = mapFormulaListToBrick(input: brick).firstObject as? Formula
                brickList.append(beginBrick)
            case kIfLogicElseBrick:
                let elseBrick = IfLogicElseBrick()
                for item in brickList.reversed() where item.brickType == kBrickType.ifBrick {
                    elseBrick.ifBeginBrick = item as? IfLogicBeginBrick
                    (item as? IfLogicBeginBrick)?.ifElseBrick = elseBrick
                }
                brickList.append(elseBrick)
            case kIfLogicEndBrick:
                let endBrick = IfLogicEndBrick()
                for item in brickList.reversed() where item.brickType == kBrickType.ifElseBrick {
                    endBrick.ifBeginBrick = (item as? IfLogicElseBrick)?.ifBeginBrick
                    endBrick.ifElseBrick = item as? IfLogicElseBrick
                    (item as? IfLogicElseBrick)?.ifBeginBrick.ifEndBrick = endBrick
                    (item as? IfLogicElseBrick)?.ifEndBrick = endBrick
                }
                brickList.append(endBrick)
            case kIfThenLogicBeginBrick:
                let beginBrick = IfThenLogicBeginBrick()
                beginBrick.ifCondition = mapFormulaListToBrick(input: brick).firstObject as? Formula
                brickList.append(beginBrick)
            case kIfThenLogicEndBrick:
                let endBrick = IfThenLogicEndBrick()
                for item in brickList.reversed() where item.brickType == kBrickType.ifThenBrick {
                    endBrick.ifBeginBrick = item as? IfThenLogicBeginBrick
                    (item as? IfThenLogicBeginBrick)?.ifEndBrick = endBrick
                }
                brickList.append(endBrick)
            case kForeverBrick:
                brickList.append(ForeverBrick())
            case kRepeatBrick:
                let repeatBrick = RepeatUntilBrick()
                repeatBrick.repeatCondition = mapFormulaListToBrick(input: brick).firstObject as? Formula
                brickList.append(repeatBrick)
            case kRepeatUntilBrick:
                let repeatUntilBrick = RepeatBrick()
                repeatUntilBrick.timesToRepeat = mapFormulaListToBrick(input: brick).firstObject as? Formula
                brickList.append(repeatUntilBrick)
            case kLoopEndBrick, kLoopEndlessBrick:
                let endBrick = LoopEndBrick()
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
                noteBrick.note = brick.noteMessage
                brickList.append(noteBrick)
            case kWaitBrick:
                let waitBrick = WaitBrick()
                if let time = mapFormulaListToBrick(input: brick).firstObject as? Formula {
                    waitBrick.timeToWaitInSeconds = time
                }
                brickList.append(waitBrick)
            case kWaitUntilBrick:
                let waitBrick = WaitUntilBrick()
                if let condition = mapFormulaListToBrick(input: brick).firstObject as? Formula {
                    waitBrick.waitCondition = condition
                }
                brickList.append(waitBrick)

            // MARK: - Motion Bricks
            case kPlaceAtBrick:
                let placeBrick = PlaceAtBrick()
                placeBrick.xPosition = mapFormulaListToBrick(input: brick).lastObject as? Formula
                placeBrick.yPosition = mapFormulaListToBrick(input: brick).firstObject as? Formula
                brickList.append(placeBrick)
            case kChangeXByNBrick:
                let changeBrick = ChangeXByNBrick()
                changeBrick.xMovement = mapFormulaListToBrick(input: brick).firstObject as? Formula
                brickList.append(changeBrick)
            case kChangeYByNBrick:
                let changeBrick = ChangeYByNBrick()
                changeBrick.yMovement = mapFormulaListToBrick(input: brick).firstObject as? Formula
                brickList.append(changeBrick)
            case kSetXBrick:
                let setBrick = SetXBrick()
                setBrick.xPosition = mapFormulaListToBrick(input: brick).firstObject as? Formula
                brickList.append(setBrick)
            case kSetYBrick:
                let setBrick = SetYBrick()
                setBrick.yPosition = mapFormulaListToBrick(input: brick).firstObject as? Formula
                brickList.append(setBrick)
            case kIfOnEdgeBounceBrick:
                brickList.append(IfOnEdgeBounceBrick())
            case kMoveNStepsBrick:
                let stepsBrick = MoveNStepsBrick()
                stepsBrick.steps = mapFormulaListToBrick(input: brick).firstObject as? Formula
                brickList.append(stepsBrick)
            case kTurnLeftBrick:
                let turnBrick = TurnLeftBrick()
                turnBrick.degrees = mapFormulaListToBrick(input: brick).firstObject as? Formula
                brickList.append(turnBrick)
            case kTurnRightBrick:
                let turnBrick = TurnRightBrick()
                turnBrick.degrees = mapFormulaListToBrick(input: brick).firstObject as? Formula
                brickList.append(turnBrick)
            case kPointInDirectionBrick:
                let pointBrick = PointInDirectionBrick()
                pointBrick.degrees = mapFormulaListToBrick(input: brick).firstObject as? Formula
                brickList.append(pointBrick)
            case kPointToBrick:
                let pointBrick = PointToBrick()
                for object in objects where object.name == brick.pointedObject {
                    pointBrick.pointedObject = mapCBObjectToSpriteObject(input: object, objects: objects)
                }
                brickList.append(pointBrick)
            case kGlideToBrick:
                let glideBrick = GlideToBrick()
                let mapping = mapFormulaListToBrick(input: brick)
                if mapping.count > 2 {
                    glideBrick.durationInSeconds = mapping[0] as? Formula
                    glideBrick.yDestination = mapping[1] as? Formula
                    glideBrick.xDestination = mapping[2] as? Formula
                }
                brickList.append(glideBrick)
            case kVibrationBrick:
                let vibrationBrick = VibrationBrick()
                vibrationBrick.durationInSeconds = mapFormulaListToBrick(input: brick).firstObject as? Formula
                brickList.append(vibrationBrick)

            default:
                print("ERROR: mapping BrickList to Script")
            }
        }
        return NSMutableArray(array: brickList)
    }
}
