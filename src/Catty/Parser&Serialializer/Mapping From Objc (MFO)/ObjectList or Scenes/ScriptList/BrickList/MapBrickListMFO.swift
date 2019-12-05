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

extension CBXMLMappingFromObjc {

    static func mapBrickList(project: Project, script: Script?, object: SpriteObject, currentObject: CBObject) -> CBBrickList? {
        guard let script = script else { return nil }
        var mappedBrickList = [CBBrick]()

        for brick in script.brickList {
            var mappedBrick = CBBrick()

            guard let tag = (brick as? BrickProtocol)?.xmlTag() else { continue }
            mappedBrick.type = tag

            switch mappedBrick.type?.uppercased() {
            // MARK: Condition Bricks
            case BroadcastBrick().xmlTag()?.uppercased():
                let brick = brick as? BroadcastBrick
                mappedBrick.broadcastMessage = brick?.broadcastMessage
            case BroadcastWaitBrick().xmlTag()?.uppercased():
                let brick = brick as? BroadcastWaitBrick
                mappedBrick.broadcastMessage = brick?.broadcastMessage
            case IfLogicBeginBrick().xmlTag()?.uppercased():
                let brick = brick as? IfLogicBeginBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.ifCondition])
            case IfThenLogicBeginBrick().xmlTag()?.uppercased():
                let brick = brick as? IfThenLogicBeginBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.ifCondition])
            case RepeatBrick().xmlTag()?.uppercased():
                let brick = brick as? RepeatBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.timesToRepeat])
            case RepeatUntilBrick().xmlTag()?.uppercased():
                let brick = brick as? RepeatUntilBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.repeatCondition])
            case NoteBrick().xmlTag()?.uppercased():
                let brick = brick as? NoteBrick
                mappedBrick.formulaTree = CBFormulaList(formulas: [CBFormula(type: "STRING", value: brick?.note, category: "NOTE")])
            case WaitBrick().xmlTag()?.uppercased():
                let brick = brick as? WaitBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.timeToWaitInSeconds])
            case WaitUntilBrick().xmlTag()?.uppercased():
                let brick = brick as? WaitUntilBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.waitCondition])
            // MARK: Motion Bricks
            case PlaceAtBrick().xmlTag()?.uppercased():
                let brick = brick as? PlaceAtBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.yPosition, brick?.xPosition])
            case ChangeXByNBrick().xmlTag()?.uppercased():
                let brick = brick as? ChangeXByNBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.xMovement])
            case ChangeYByNBrick().xmlTag()?.uppercased():
                let brick = brick as? ChangeYByNBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.yMovement])
            case SetXBrick().xmlTag()?.uppercased():
                let brick = brick as? SetXBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.xPosition])
            case SetYBrick().xmlTag()?.uppercased():
                let brick = brick as? SetYBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.yPosition])
            case MoveNStepsBrick().xmlTag()?.uppercased():
                let brick = brick as? MoveNStepsBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.steps])
            case TurnLeftBrick().xmlTag()?.uppercased():
                let brick = brick as? TurnLeftBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.degrees])
            case TurnRightBrick().xmlTag()?.uppercased():
                let brick = brick as? TurnRightBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.degrees])
            case PointInDirectionBrick().xmlTag()?.uppercased():
                let brick = brick as? PointInDirectionBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.degrees])
            case PointToBrick().xmlTag()?.uppercased():
                let brick = brick as? PointToBrick
                mappedBrick.pointedObjectReference = "../../" + (resolveObjectPath(project: project, object: brick?.pointedObject) ?? "")
            case GlideToBrick().xmlTag()?.uppercased():
                let brick = brick as? GlideToBrick
                if brick?.xDestination?.category?.isEmpty ?? true || brick?.yDestination?.category?.isEmpty ?? true || brick?.durationInSeconds?.category?.isEmpty ?? true {
                    brick?.xDestination?.category = "X_DESTINATION"
                    brick?.yDestination?.category = "Y_DESTINATION"
                    brick?.durationInSeconds?.category = "DURATION_IN_SECONDS"
                }
                var serializationArr = [Formula?]()
                if let serializationOrder = brick?.serializationOrder as? [String] {
                    for orderIndex in serializationOrder {
                        switch orderIndex {
                        case "X":
                            serializationArr.append(brick?.xDestination)
                        case "Y":
                            serializationArr.append(brick?.yDestination)
                        default:
                            serializationArr.append(brick?.durationInSeconds)
                        }
                    }
                }
                mappedBrick.formulaTree = mapFormulaList(formulas: serializationArr)
            case VibrationBrick().xmlTag()?.uppercased():
                let brick = brick as? VibrationBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.durationInSeconds])
            // MARK: Look Bricks
            case SetBackgroundBrick().xmlTag()?.uppercased():
                let brick = brick as? SetBackgroundBrick
                mappedBrick.lookReference = resolveLookPath(look: brick?.look, currentObject: currentObject)
            case SetLookBrick().xmlTag()?.uppercased():
                let brick = brick as? SetLookBrick
                mappedBrick.lookReference = resolveLookPath(look: brick?.look, currentObject: currentObject)
            case SetSizeToBrick().xmlTag()?.uppercased():
                let brick = brick as? SetSizeToBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.size])
            case ChangeSizeByNBrick().xmlTag()?.uppercased():
                let brick = brick as? ChangeSizeByNBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.size])
            case SetTransparencyBrick().xmlTag()?.uppercased(), "SETGHOSTEFFECTBRICK":
                let brick = brick as? SetTransparencyBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.transparency])
            case ChangeTransparencyByNBrick().xmlTag()?.uppercased(), "CHANGEGHOSTEFFECTBYNBRICK":
                let brick = brick as? ChangeTransparencyByNBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.changeTransparency])
            case SetBrightnessBrick().xmlTag()?.uppercased():
                let brick = brick as? SetBrightnessBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.brightness])
            case ChangeBrightnessByNBrick().xmlTag()?.uppercased():
                let brick = brick as? ChangeBrightnessByNBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.changeBrightness])
            case SetColorBrick().xmlTag()?.uppercased():
                let brick = brick as? SetColorBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.color])
            case ChangeColorByNBrick().xmlTag()?.uppercased():
                let brick = brick as? ChangeColorByNBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.changeColor])
            case FlashBrick().xmlTag()?.uppercased(), "LEDONBRICK", "LEDOFFBRICK":
                let brick = brick as? FlashBrick
                mappedBrick.spinnerSelectionID = String(brick?.flashChoice ?? 0)
            case CameraBrick().xmlTag()?.uppercased():
                let brick = brick as? CameraBrick
                mappedBrick.spinnerSelectionID = String(brick?.cameraChoice ?? 0)
            case ChooseCameraBrick().xmlTag()?.uppercased():
                let brick = brick as? ChooseCameraBrick
                mappedBrick.spinnerSelectionID = String(brick?.cameraPosition ?? 0)
            case ThinkBubbleBrick().xmlTag()?.uppercased():
                let brick = brick as? ThinkBubbleBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.formula])
            case ThinkForBubbleBrick().xmlTag()?.uppercased():
                let brick = brick as? ThinkForBubbleBrick
                mappedBrick.formulaList = mapFormulaList(formulas: [brick?.intFormula, brick?.stringFormula])
            // MARK: Sound Bricks
            case PlaySoundBrick().xmlTag()?.uppercased():
                let brick = brick as? PlaySoundBrick
                mappedBrick.soundReference = resolveSoundPath(sound: brick?.sound, currentObject: currentObject)
            case SetVolumeToBrick().xmlTag()?.uppercased():
                let brick = brick as? SetVolumeToBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.volume])
            case ChangeVolumeByNBrick().xmlTag()?.uppercased():
                let brick = brick as? ChangeVolumeByNBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.volume])
            case SpeakBrick().xmlTag()?.uppercased():
                let brick = brick as? SpeakBrick
                mappedBrick.noteMessage = brick?.text
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.formula])
            case SpeakAndWaitBrick().xmlTag()?.uppercased():
                let brick = brick as? SpeakAndWaitBrick
                mappedBrick.noteMessage = brick?.text
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.formula])
            // MARK: Variable Bricks
            case SetVariableBrick().xmlTag()?.uppercased():
                let brick = brick as? SetVariableBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.variableFormula])
                let uVar = mapUserVariableWithLocalCheck(project: project, userVariable: brick?.userVariable, object: object, isList: false)
                mappedBrick.userVariable = uVar?.value
                mappedBrick.userVariableReference = uVar?.reference
            case ChangeVariableBrick().xmlTag()?.uppercased():
                let brick = brick as? ChangeVariableBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.variableFormula])
                let uVar = mapUserVariableWithLocalCheck(project: project, userVariable: brick?.userVariable, object: object, isList: false)
                mappedBrick.userVariable = uVar?.value
                mappedBrick.userVariableReference = uVar?.reference
            case ShowTextBrick().xmlTag()?.uppercased():
                let brick = brick as? ShowTextBrick
                mappedBrick.xPosition = mapFormula(formula: brick?.xFormula)
                mappedBrick.yPosition = mapFormula(formula: brick?.yFormula)
                let uVar = mapUserVariableWithLocalCheck(project: project, userVariable: brick?.userVariable, object: object, isList: false)
                mappedBrick.userVariable = uVar?.value
                mappedBrick.userVariableReference = uVar?.reference
            case HideTextBrick().xmlTag()?.uppercased():
                let brick = brick as? HideTextBrick
                let uVar = mapUserVariableWithLocalCheck(project: project, userVariable: brick?.userVariable, object: object, isList: false)
                mappedBrick.userVariable = uVar?.value
                mappedBrick.userVariableReference = uVar?.reference
            case AddItemToUserListBrick().xmlTag()?.uppercased():
                let brick = brick as? AddItemToUserListBrick
                mappedBrick.formulaList = mapFormulaList(formulas: [brick?.listFormula])
                let uVar = mapUserVariableWithLocalCheck(project: project, userVariable: brick?.userList, object: object, isList: true)
                mappedBrick.userList = uVar?.value
                mappedBrick.userVariableReference = uVar?.reference
            case DeleteItemOfUserListBrick().xmlTag()?.uppercased():
                let brick = brick as? DeleteItemOfUserListBrick
                mappedBrick.formulaList = mapFormulaList(formulas: [brick?.listFormula])
                let uVar = mapUserVariableWithLocalCheck(project: project, userVariable: brick?.userList, object: object, isList: true)
                mappedBrick.userList = uVar?.value
                mappedBrick.userVariableReference = uVar?.reference
            case InsertItemIntoUserListBrick().xmlTag()?.uppercased():
                let brick = brick as? InsertItemIntoUserListBrick
                mappedBrick.formulaList = mapFormulaList(formulas: [brick?.index, brick?.elementFormula])
                let uVar = mapUserVariableWithLocalCheck(project: project, userVariable: brick?.userList, object: object, isList: true)
                mappedBrick.userList = uVar?.value
                mappedBrick.userVariableReference = uVar?.reference
            case ReplaceItemInUserListBrick().xmlTag()?.uppercased():
                let brick = brick as? ReplaceItemInUserListBrick
                mappedBrick.formulaList = mapFormulaList(formulas: [brick?.elementFormula, brick?.index])
                let uVar = mapUserVariableWithLocalCheck(project: project, userVariable: brick?.userList, object: object, isList: true)
                mappedBrick.userList = uVar?.value
                mappedBrick.userVariableReference = uVar?.reference
            // MARK: Arduino Bricks
            case ArduinoSendDigitalValueBrick().xmlTag()?.uppercased():
                let brick = brick as? ArduinoSendDigitalValueBrick
                mappedBrick.formulaList = mapFormulaList(formulas: [brick?.pin, brick?.value])
            case ArduinoSendPWMValueBrick().xmlTag()?.uppercased():
                let brick = brick as? ArduinoSendPWMValueBrick
                mappedBrick.formulaList = mapFormulaList(formulas: [brick?.pin, brick?.value])
            // MARK: Alternative Bricks
            case GoNStepsBackBrick().xmlTag()?.uppercased():
                let brick = brick as? GoNStepsBackBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.steps])
            case SayBubbleBrick().xmlTag()?.uppercased():
                let brick = brick as? SayBubbleBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.formula])
            case SayForBubbleBrick().xmlTag()?.uppercased():
                let brick = brick as? SayForBubbleBrick
                mappedBrick.formulaList = mapFormulaList(formulas: [brick?.intFormula, brick?.stringFormula])
            default:
                break
            }
            mappedBrick.commentedOut = (brick as? Brick)?.commentedOut ?? "false"
            mappedBrickList.append(mappedBrick)
            CBXMLMappingFromObjc.currentSerializationPosition.2 += 1
        }

        return CBBrickList(bricks: mappedBrickList)
    }
}
