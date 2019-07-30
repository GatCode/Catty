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

    // MARK: - Map Scenes
    static func mapScenesToCBProject(project: Project) -> [CBProjectScene] {
        var mappedScene = CBProjectScene()

        mappedScene.name = "Szene 1"
        mappedScene.objectList = mapObjectList(project: project)
        mappedScene.data = mapData(project: project)
        mappedScene.originalHeight = project.header.screenHeight.stringValue
        mappedScene.originalWidth = project.header.screenWidth.stringValue

        return [mappedScene]
    }

    static func mapObjectList(project: Project) -> CBObjectList {
        var mappedObjectList = [CBObject]()

        for object in project.objectList {
            var mappedObject = CBObject()
            mappedObject.name = (object as? SpriteObject)?.name

            mappedObject.lookList = mapLookList(project: project, object: object as? SpriteObject)
            mappedObject.soundList = mapSoundList(project: project, object: object as? SpriteObject)
            mappedObject.scriptList = mapScriptList(project: project, object: object as? SpriteObject, currentObject: mappedObject)
            mappedObject.userBrickList = CBUserBrickList(userBricks: nil)
            mappedObject.nfcTagList = CBNfcTagList(nfcTags: nil)

            mappedObjectList.append(mappedObject)
            CBXMLMappingFromObjc.objectList.append((object as? SpriteObject, CBXMLMappingFromObjc.currentSerializationPosition))
            CBXMLMappingFromObjc.currentSerializationPosition.0 += 1
            CBXMLMappingFromObjc.currentSerializationPosition.1 = 0
        }

        return CBObjectList(objects: mappedObjectList)
    }

    static func mapLookList(project: Project, object: SpriteObject?) -> CBLookList? {
        guard let object = object else { return nil }
        guard let lookList = object.lookList else { return nil }
        var mappedLooks = [CBLook]()

        for look in lookList {
            if let look = look as? Look {
                mappedLooks.append(CBLook(name: look.name, fileName: look.fileName))
            }
        }

        return CBLookList(looks: mappedLooks)
    }

    static func mapSoundList(project: Project, object: SpriteObject?) -> CBSoundList? {
        guard let object = object else { return nil }
        guard let soundList = object.soundList else { return nil }
        var mappedSounds = [CBSound]()

        for sound in soundList {
            if let sound = sound as? Sound {
                mappedSounds.append(CBSound(fileName: sound.fileName, name: sound.name, reference: nil))
            }
        }

        return CBSoundList(sounds: mappedSounds)
    }

    static func mapScriptList(project: Project, object: SpriteObject?, currentObject: CBObject) -> CBScriptList? {
        guard let object = object else { return nil }
        var mappedScriptList = [CBScript]()

        for script in object.scriptList {
            var mappedScript = CBScript()

            mappedScript.brickList = mapBrickList(project: project, script: script as? Script, object: object, currentObject: currentObject)
            mappedScript.isUserScript = (script as? Script)?.isUserScript
            mappedScript.receivedMessage = (script as? Script)?.receivedMsg
            mappedScript.action = (script as? Script)?.action

            if let brickType = (script as? Script)?.brickType {
                mappedScript.type = BrickManager.shared()?.className(for: brickType)
            }

            mappedScriptList.append(mappedScript)
            CBXMLMappingFromObjc.currentSerializationPosition.1 += 1
            CBXMLMappingFromObjc.currentSerializationPosition.2 = 0
        }

        return CBScriptList(scripts: mappedScriptList)
    }

    static func resolveLookPath(look: Look?, currentObject: CBObject) -> String? {
        guard let lookList = currentObject.lookList?.looks else { return nil }

        for (idx, refLook) in lookList.enumerated() where refLook.name == look?.name {
            return "../../../../../lookList/" + (idx == 0 ? "look" : "look[\(idx + 1)]")
        }

        return nil
    }

    static func resolveSoundPath(sound: Sound?, currentObject: CBObject) -> String? {
        guard let soundList = currentObject.soundList?.sounds else { return nil }

        for (idx, refSound) in soundList.enumerated() where refSound.name == sound?.name {
            return "../../../../../soundList/" + (idx == 0 ? "sound" : "sound[\(idx + 1)]")
        }

        return nil
    }

    static func mapBrickList(project: Project, script: Script?, object: SpriteObject, currentObject: CBObject) -> CBBrickList? {
        guard let script = script else { return nil }
        var mappedBrickList = [CBBrick]()

        for brick in script.brickList {
            var mappedBrick = CBBrick()

            if let brickType = (brick as? Brick)?.brickType {
                mappedBrick.type = BrickManager.shared()?.className(for: brickType)
            }

            switch mappedBrick.type?.uppercased() {
            // MARK: Condition Bricks
            case kBroadcastBrick.uppercased():
                let brick = brick as? BroadcastBrick
                mappedBrick.broadcastMessage = brick?.broadcastMessage
            case kBroadcastWaitBrick.uppercased():
                let brick = brick as? BroadcastWaitBrick
                mappedBrick.broadcastMessage = brick?.broadcastMessage
            case kIfLogicBeginBrick.uppercased():
                let brick = brick as? IfLogicBeginBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.ifCondition])
            case kIfThenLogicBeginBrick.uppercased():
                let brick = brick as? IfThenLogicBeginBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.ifCondition])
            case kRepeatBrick.uppercased():
                let brick = brick as? RepeatBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.timesToRepeat])
            case kRepeatUntilBrick.uppercased():
                let brick = brick as? RepeatUntilBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.repeatCondition])
            case kNoteBrick.uppercased():
                let brick = brick as? NoteBrick
                mappedBrick.formulaTree = CBFormulaList(formulas: [CBFormula(type: "STRING", value: brick?.note, category: "NOTE")])
            case kWaitBrick.uppercased():
                let brick = brick as? WaitBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.timeToWaitInSeconds])
            case kWaitUntilBrick.uppercased():
                let brick = brick as? WaitUntilBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.waitCondition])
            // MARK: Motion Bricks
            case kPlaceAtBrick.uppercased():
                let brick = brick as? PlaceAtBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.yPosition, brick?.xPosition])
            case kChangeXByNBrick.uppercased():
                let brick = brick as? ChangeXByNBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.xMovement])
            case kChangeYByNBrick.uppercased():
                let brick = brick as? ChangeYByNBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.yMovement])
            case kSetXBrick.uppercased():
                let brick = brick as? SetXBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.xPosition])
            case kSetYBrick.uppercased():
                let brick = brick as? SetYBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.yPosition])
            case kMoveNStepsBrick.uppercased():
                let brick = brick as? MoveNStepsBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.steps])
            case kTurnLeftBrick.uppercased():
                let brick = brick as? TurnLeftBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.degrees])
            case kTurnRightBrick.uppercased():
                let brick = brick as? TurnRightBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.degrees])
            case kPointInDirectionBrick.uppercased():
                let brick = brick as? PointInDirectionBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.degrees])
            case kPointToBrick.uppercased():
                let brick = brick as? PointToBrick
                mappedBrick.pointedObjectReference = "../../" + (resolveObjectPath(project: project, object: brick?.pointedObject) ?? "")
            case kGlideToBrick.uppercased():
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
            case kVibrationBrick.uppercased():
                let brick = brick as? VibrationBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.durationInSeconds])
            // MARK: Look Bricks
            case kSetBackgroundBrick.uppercased():
                let brick = brick as? SetBackgroundBrick
                mappedBrick.lookReference = resolveLookPath(look: brick?.look, currentObject: currentObject)
            case kSetLookBrick.uppercased():
                let brick = brick as? SetLookBrick
                mappedBrick.lookReference = resolveLookPath(look: brick?.look, currentObject: currentObject)
            case kSetSizeToBrick.uppercased():
                let brick = brick as? SetSizeToBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.size])
            case kChangeSizeByNBrick.uppercased():
                let brick = brick as? ChangeSizeByNBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.size])
            case kSetTransparencyBrick.uppercased(), kSetGhostEffectBrick.uppercased():
                let brick = brick as? SetTransparencyBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.transparency])
            case kChangeTransparencyByNBrick.uppercased(), kChangeGhostEffectByNBrick.uppercased():
                let brick = brick as? ChangeTransparencyByNBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.changeTransparency])
            case kSetBrightnessBrick.uppercased():
                let brick = brick as? SetBrightnessBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.brightness])
            case kChangeBrightnessByNBrick.uppercased():
                let brick = brick as? ChangeBrightnessByNBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.changeBrightness])
            case kSetColorBrick.uppercased():
                let brick = brick as? SetColorBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.color])
            case kChangeColorByNBrick.uppercased():
                let brick = brick as? ChangeColorByNBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.changeColor])
            case kFlashBrick.uppercased(), kLedOnBrick.uppercased(), kLedOffBrick.uppercased():
                let brick = brick as? FlashBrick
                mappedBrick.spinnerSelectionID = String(brick?.flashChoice ?? 0)
            case kCameraBrick.uppercased():
                let brick = brick as? CameraBrick
                mappedBrick.spinnerSelectionID = String(brick?.cameraChoice ?? 0)
            case kChooseCameraBrick.uppercased():
                let brick = brick as? ChooseCameraBrick
                mappedBrick.spinnerSelectionID = String(brick?.cameraPosition ?? 0)
            case kThinkBubbleBrick.uppercased():
                let brick = brick as? ThinkBubbleBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.formula])
            case kThinkForBubbleBrick.uppercased():
                let brick = brick as? ThinkForBubbleBrick
                mappedBrick.formulaList = mapFormulaList(formulas: [brick?.intFormula, brick?.stringFormula])
            // MARK: Sound Bricks
            case kPlaySoundBrick.uppercased():
                let brick = brick as? PlaySoundBrick
                mappedBrick.soundReference = resolveSoundPath(sound: brick?.sound, currentObject: currentObject)
            case kSetVolumeToBrick.uppercased():
                let brick = brick as? SetVolumeToBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.volume])
            case kChangeVolumeByNBrick.uppercased():
                let brick = brick as? ChangeVolumeByNBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.volume])
            case kSpeakBrick.uppercased():
                let brick = brick as? SpeakBrick
                mappedBrick.noteMessage = brick?.text
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.formula])
            case kSpeakAndWaitBrick.uppercased():
                let brick = brick as? SpeakAndWaitBrick
                mappedBrick.noteMessage = brick?.text
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.formula])
            // MARK: Variable Bricks
            case kSetVariableBrick.uppercased():
                let brick = brick as? SetVariableBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.variableFormula])
                let uVar = mapUserVariableWithLocalCheck(project: project, userVariable: brick?.userVariable, object: object, isList: false)
                mappedBrick.userVariable = uVar?.value
                mappedBrick.userVariableReference = uVar?.reference
            case kChangeVariableBrick.uppercased():
                let brick = brick as? ChangeVariableBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.variableFormula])
                let uVar = mapUserVariableWithLocalCheck(project: project, userVariable: brick?.userVariable, object: object, isList: false)
                mappedBrick.userVariable = uVar?.value
                mappedBrick.userVariableReference = uVar?.reference
            case kShowTextBrick.uppercased():
                let brick = brick as? ShowTextBrick
                mappedBrick.xPosition = mapFormula(formula: brick?.xFormula)
                mappedBrick.yPosition = mapFormula(formula: brick?.yFormula)
                let uVar = mapUserVariableWithLocalCheck(project: project, userVariable: brick?.userVariable, object: object, isList: false)
                mappedBrick.userVariable = uVar?.value
                mappedBrick.userVariableReference = uVar?.reference
            case kHideTextBrick.uppercased():
                let brick = brick as? HideTextBrick
                let uVar = mapUserVariableWithLocalCheck(project: project, userVariable: brick?.userVariable, object: object, isList: false)
                mappedBrick.userVariable = uVar?.value
                mappedBrick.userVariableReference = uVar?.reference
            case kAddItemToUserListBrick.uppercased():
                let brick = brick as? AddItemToUserListBrick
                mappedBrick.formulaList = mapFormulaList(formulas: [brick?.listFormula])
                let uVar = mapUserVariableWithLocalCheck(project: project, userVariable: brick?.userList, object: object, isList: true)
                mappedBrick.userList = uVar?.value
                mappedBrick.userVariableReference = uVar?.reference
            case kDeleteItemOfUserListBrick.uppercased():
                let brick = brick as? DeleteItemOfUserListBrick
                mappedBrick.formulaList = mapFormulaList(formulas: [brick?.listFormula])
                let uVar = mapUserVariableWithLocalCheck(project: project, userVariable: brick?.userList, object: object, isList: true)
                mappedBrick.userList = uVar?.value
                mappedBrick.userVariableReference = uVar?.reference
            case kInsertItemIntoUserListBrick.uppercased():
                let brick = brick as? InsertItemIntoUserListBrick
                mappedBrick.formulaList = mapFormulaList(formulas: [brick?.index, brick?.elementFormula])
                let uVar = mapUserVariableWithLocalCheck(project: project, userVariable: brick?.userList, object: object, isList: true)
                mappedBrick.userList = uVar?.value
                mappedBrick.userVariableReference = uVar?.reference
            case kReplaceItemInUserListBrick.uppercased():
                let brick = brick as? ReplaceItemInUserListBrick
                mappedBrick.formulaList = mapFormulaList(formulas: [brick?.elementFormula, brick?.index])
                let uVar = mapUserVariableWithLocalCheck(project: project, userVariable: brick?.userList, object: object, isList: true)
                mappedBrick.userList = uVar?.value
                mappedBrick.userVariableReference = uVar?.reference
            // MARK: Arduino Bricks
            case kArduinoSendDigitalValueBrick.uppercased():
                let brick = brick as? ArduinoSendDigitalValueBrick
                mappedBrick.formulaList = mapFormulaList(formulas: [brick?.pin, brick?.value])
            case kArduinoSendPWMValueBrick.uppercased():
                let brick = brick as? ArduinoSendPWMValueBrick
                mappedBrick.formulaList = mapFormulaList(formulas: [brick?.pin, brick?.value])
            // MARK: Alternative Bricks
            case kGoNStepsBackBrick.uppercased():
                let brick = brick as? GoNStepsBackBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.steps])
            case kSayBubbleBrick.uppercased():
                let brick = brick as? SayBubbleBrick
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.formula])
            case kSayForBubbleBrick.uppercased():
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

    static func mapFormulaList(formulas: [Formula?]) -> CBFormulaList? {
        var mappedFormulas = [CBFormula]()

        for formula in formulas {
            if let mappedFormula = mapFormula(formula: formula) {
                mappedFormulas.append(mappedFormula)
            }
        }

        return CBFormulaList(formulas: mappedFormulas)
    }

    static func mapFormula(formula: Formula?) -> CBFormula? {
        guard let formula = formula else { return nil }
        guard let parentElement = formula.formulaTree else { return nil }

        let type = parentElement.string(for: parentElement.type)
        let value = parentElement.value
        let category = formula.category
        let left = mapFormulaChild(formulaElement: parentElement.leftChild)
        let right = mapFormulaChild(formulaElement: parentElement.rightChild)

        let mappedFormula = CBFormula(type: type, value: value, category: category, leftChild: left, rightChild: right)

        return mappedFormula
    }

    static func mapFormulaChild(formulaElement: FormulaElement?) -> CBLRChild? {
        guard let formulaElement = formulaElement else { return nil }

        var mappedChild = CBLRChild()
        mappedChild.type = formulaElement.string(for: formulaElement.type)
        mappedChild.value = formulaElement.value
        mappedChild.leftChild = [mapFormulaChild(formulaElement: formulaElement.leftChild)]
        mappedChild.rightChild = [mapFormulaChild(formulaElement: formulaElement.rightChild)]

        return mappedChild
    }

    static func mapUserVariableWithLocalCheck(project: Project, userVariable: UserVariable?, object: SpriteObject, isList: Bool) -> CBUserVariable? {
        guard let userVariable = userVariable else { return nil }

        if globalVariableList.contains(where: { $0.0 == userVariable.name }) == false {
            for (index, element) in CBXMLMappingFromObjc.localVariableList.enumerated() where element.0 == object {
                if CBXMLMappingFromObjc.localVariableList[index].1.contains(where: { $0.contains(where: { $0.key == userVariable }) }) == false {
                    CBXMLMappingFromObjc.localVariableList[index].1.append([userVariable: CBXMLMappingFromObjc.currentSerializationPosition])
                }
                return mapUserVariable(project: project, userVariable: userVariable, isList: isList)
            }
            CBXMLMappingFromObjc.localVariableList.append((object, [[userVariable: CBXMLMappingFromObjc.currentSerializationPosition]]))
        }

        return mapUserVariable(project: project, userVariable: userVariable, isList: isList)
    }

    static func mapUserVariable(project: Project, userVariable: UserVariable?, isList: Bool) -> CBUserVariable? {
        guard let userVariable = userVariable else { return nil }

        if CBXMLMappingFromObjc.userVariableList.contains(where: { $0.0 == userVariable }) == false {
            CBXMLMappingFromObjc.userVariableList.append((userVariable, CBXMLMappingFromObjc.currentSerializationPosition))
            return(CBUserVariable(value: userVariable.name, reference: nil))
        }

        return CBUserVariable(value: nil, reference: resolveUserVariablePath(project: project, userVariable: userVariable, isList: isList))
    }

    static func resolveUserVariablePath(project: Project, userVariable: UserVariable?, isList: Bool) -> String? {
        let currentObjectPos = CBXMLMappingFromObjc.currentSerializationPosition.0
        let currentScriptPos = CBXMLMappingFromObjc.currentSerializationPosition.1
        let endPart = isList ? "userList" : "userVariable"

        if let referencedUserVariable = CBXMLMappingFromObjc.userVariableList.first(where: { $0.0 == userVariable }) {
            let referencedPosition = referencedUserVariable.1

            if referencedPosition.0 == currentObjectPos {
                if referencedPosition.1 == currentScriptPos {
                    return "../../" + (referencedPosition.2 == 0 ? "brick/" : "brick[\(referencedPosition.2 + 1)]/") + endPart
                } else {
                    let scrString = referencedPosition.1 == 0 ? "script/" : "script[\(referencedPosition.1 + 1)]/"
                    let brString = referencedPosition.2 == 0 ? "brick/" : "brick[\(referencedPosition.2 + 1)]/"
                    return "../../../../" + scrString + "brickList/" + brString + endPart
                }
            } else {
                let objString = referencedPosition.0 == 0 ? "object/" : "object[\(referencedPosition.0 + 1)]/"
                let scrString = referencedPosition.1 == 0 ? "script/" : "script[\(referencedPosition.1 + 1)]/"
                let brString = referencedPosition.2 == 0 ? "brick/" : "brick[\(referencedPosition.2 + 1)]/"
                return "../../../../../../" + objString + "scriptList/" + scrString + "brickList/" + brString + endPart
            }
        }

        return nil
    }

    // MARK: - Map Data
    static func mapData(project: Project) -> CBProjectData {
        var mappedData = CBProjectData()

        mappedData.objectVariableList = mapObjectVariableList(project: project)
        mappedData.objectListOfList = mapObjectListOfLists(project: project)
        mappedData.userBrickVariableList = CBUserBrickVariableList(name: nil)
        return mappedData
    }
}
