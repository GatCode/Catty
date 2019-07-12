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

enum CBXMLMappingFromObjc {

    private static var userVariableList = [(UserVariable?, (Int, Int, Int))]() // contains local and global userVariables
    private static var objectList = [(SpriteObject?, (Int, Int, Int))]()
    private static var currentSerializationPosition = (0, 0, 0)
    private static var globalVariableList = [(String, Bool)]() // isList: Bool
    private static var localVariableList = [(SpriteObject?, [[UserVariable?: (Int, Int, Int)]])]()

    static func mapProjectToCBProject(project: Project) -> CBProject? {

        CBXMLMappingFromObjc.userVariableList.removeAll()
        CBXMLMappingFromObjc.globalVariableList.removeAll()
        CBXMLMappingFromObjc.localVariableList.removeAll()

        var mappedProject = CBProject()

        // TODO: map header
        // TODO: map settings
        CBXMLMappingFromObjc.extractGlobalUserVariables(project: project)
        mappedProject.scenes = CBXMLMappingFromObjc.mapScenesToCBProject(project: project)
        mappedProject.programVariableList = CBXMLMappingFromObjc.mapProgramVariableList(project: project)
        mappedProject.programListOfLists = CBXMLMappingFromObjc.mapProgramListOfLists(project: project)

        return nil
    }
}

extension CBXMLMappingFromObjc {

    // MARK: - Extract Global UserVariables
    private static func extractGlobalUserVariables(project: Project) {
        project.variables.programVariableList.forEach { variable in
            if let variable = variable as? UserVariable, CBXMLMappingFromObjc.globalVariableList.contains(where: { $0.0 == variable.name }) == false {
                CBXMLMappingFromObjc.globalVariableList.append((variable.name, false))
            }
        }

        project.variables.programListOfLists.forEach { variable in
            if let variable = variable as? UserVariable, CBXMLMappingFromObjc.globalVariableList.contains(where: { $0.0 == variable.name }) == false {
                CBXMLMappingFromObjc.globalVariableList.append((variable.name, true))
            }
        }
    }

    // MARK: - Map Scenes
    private static func mapScenesToCBProject(project: Project) -> [CBProjectScene] {
        var mappedScene = CBProjectScene()

        // TODO: map name
        mappedScene.objectList = mapObjectList(project: project)
        mappedScene.data = mapData(project: project)
        // TODO: map originalWidth
        // TODO: map originalHeight

        return [mappedScene]
    }

    private static func mapObjectList(project: Project) -> CBObjectList {
        var mappedObjectList = [CBObject]()

        for object in project.objectList {
            var mappedObject = CBObject()

            mappedObject.scriptList = mapScriptList(project: project, object: object as? SpriteObject)
            mappedObject.lookList = mapLookList(project: project, object: object as? SpriteObject)
            mappedObject.soundList = mapSoundList(project: project, object: object as? SpriteObject)
            // TODO: map userBricks
            // TODO: map nfcTagList

            mappedObjectList.append(mappedObject)
            CBXMLMappingFromObjc.objectList.append((object as? SpriteObject, CBXMLMappingFromObjc.currentSerializationPosition))
            CBXMLMappingFromObjc.currentSerializationPosition.0 += 1
            CBXMLMappingFromObjc.currentSerializationPosition.1 = 0
        }

        return CBObjectList(object: mappedObjectList)
    }

    private static func mapLookList(project: Project, object: SpriteObject?) -> CBLookList? {
        guard let object = object else { return nil }
        guard let lookList = object.lookList else { return nil }
        var mappedLooks = [CBLook]()

        for look in lookList {
            // TODO: resolve the reference
        }

        return CBLookList(look: mappedLooks)
    }

    private static func mapSoundList(project: Project, object: SpriteObject?) -> CBSoundList? {
        guard let object = object else { return nil }
        guard let soundList = object.soundList else { return nil }
        var mappedSounds = [CBSound]()

        for sound in soundList {
            // TODO: resolve the reference
        }

        return CBSoundList(sound: mappedSounds)
    }

    private static func mapScriptList(project: Project, object: SpriteObject?) -> CBScriptList? {
        guard let object = object else { return nil }
        var mappedScriptList = [CBScript]()

        for script in object.scriptList {
            var mappedScript = CBScript()

            mappedScript.brickList = mapBrickList(project: project, script: script as? Script, object: object)
            // TODO: map commentedOut
            // TODO: map isUserScript

            mappedScriptList.append(mappedScript)
            CBXMLMappingFromObjc.currentSerializationPosition.1 += 1
            CBXMLMappingFromObjc.currentSerializationPosition.2 = 0
        }

        return CBScriptList(script: mappedScriptList)
    }

    private static func resolveLook(object: SpriteObject, look: Look?) -> (CBLook?, String?) {

        // TODO: do some magic here

        return (nil, nil)
    }

    private static func resolveSound(object: SpriteObject, sound: Sound?) -> (CBSound?, String?) {

        // TODO: do some magic here

        return (nil, nil)
    }

    private static func mapBrickList(project: Project, script: Script?, object: SpriteObject) -> CBBrickList? {
        guard let script = script else { return nil }
        var mappedBrickList = [CBBrick]()

        for brick in script.brickList {
            var mappedBrick = CBBrick()

            switch (brick as? Brick)?.name.uppercased() {
            // MARK: Condition Bricks
            case kLocalizedBroadcast.uppercased():
                let brick = brick as? BroadcastBrick
                mappedBrick.name = brick?.name
                mappedBrick.broadcastMessage = brick?.broadcastMessage
            case kBroadcastWaitBrick.uppercased():
                let brick = brick as? BroadcastWaitBrick
                mappedBrick.name = brick?.name
                mappedBrick.broadcastMessage = brick?.broadcastMessage
            case kIfLogicBeginBrick.uppercased():
                let brick = brick as? IfLogicBeginBrick
                mappedBrick.name = brick?.name
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.ifCondition])
            case kIfLogicElseBrick.uppercased():
                let brick = brick as? IfLogicElseBrick
                mappedBrick.name = brick?.name
            case kIfLogicEndBrick.uppercased():
                let brick = brick as? IfLogicEndBrick
                mappedBrick.name = brick?.name
            case kIfThenLogicBeginBrick.uppercased():
                let brick = brick as? IfThenLogicBeginBrick
                mappedBrick.name = brick?.name
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.ifCondition])
            case kIfThenLogicEndBrick.uppercased():
                let brick = brick as? IfThenLogicEndBrick
                mappedBrick.name = brick?.name
            case kForeverBrick.uppercased():
                let brick = brick as? ForeverBrick
                mappedBrick.name = brick?.name
            case kRepeatBrick.uppercased():
                let brick = brick as? RepeatBrick
                mappedBrick.name = brick?.name
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.timesToRepeat])
            case kRepeatUntilBrick.uppercased():
                let brick = brick as? RepeatUntilBrick
                mappedBrick.name = brick?.name
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.repeatCondition])
            case kLoopEndBrick.uppercased():
                let brick = brick as? LoopEndBrick
                mappedBrick.name = brick?.name
            case kNoteBrick.uppercased():
                let brick = brick as? NoteBrick
                mappedBrick.name = brick?.name
                mappedBrick.noteMessage = brick?.note
            case kWaitBrick.uppercased():
                let brick = brick as? WaitBrick
                mappedBrick.name = brick?.name
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.timeToWaitInSeconds])
            case kWaitUntilBrick.uppercased():
                let brick = brick as? WaitUntilBrick
                mappedBrick.name = brick?.name
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.waitCondition])
            // MARK: Motion Bricks
            case kPlaceAtBrick.uppercased():
                let brick = brick as? PlaceAtBrick
                mappedBrick.name = brick?.name
                mappedBrick.xPosition = mapFormula(formula: brick?.xPosition)
                mappedBrick.yPosition = mapFormula(formula: brick?.yPosition)
            case kChangeXByNBrick.uppercased():
                let brick = brick as? ChangeXByNBrick
                mappedBrick.name = brick?.name
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.xMovement])
            case kChangeYByNBrick.uppercased():
                let brick = brick as? ChangeYByNBrick
                mappedBrick.name = brick?.name
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.yMovement])
            case kSetXBrick.uppercased():
                let brick = brick as? SetXBrick
                mappedBrick.name = brick?.name
                mappedBrick.xPosition = mapFormula(formula: brick?.xPosition)
            case kSetYBrick.uppercased():
                let brick = brick as? SetYBrick
                mappedBrick.name = brick?.name
                mappedBrick.yPosition = mapFormula(formula: brick?.yPosition)
            case kIfOnEdgeBounceBrick.uppercased():
                mappedBrick.name = kIfOnEdgeBounceBrick
            case kMoveNStepsBrick.uppercased():
                let brick = brick as? MoveNStepsBrick
                mappedBrick.name = brick?.name
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.steps])
            case kTurnLeftBrick.uppercased():
                let brick = brick as? TurnLeftBrick
                mappedBrick.name = brick?.name
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.degrees])
            case kTurnRightBrick.uppercased():
                let brick = brick as? TurnRightBrick
                mappedBrick.name = brick?.name
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.degrees])
            case kPointInDirectionBrick.uppercased():
                let brick = brick as? PointInDirectionBrick
                mappedBrick.name = brick?.name
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.degrees])
            case kPointToBrick.uppercased():
                let brick = brick as? PointToBrick
                mappedBrick.name = brick?.name
                mappedBrick.pointedObject = resolveObjectPath(project: project, object: brick?.pointedObject)
            case kGlideToBrick.uppercased():
                let brick = brick as? GlideToBrick
                mappedBrick.name = brick?.name
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.durationInSeconds, brick?.yDestination, brick?.xDestination])
            case kVibrationBrick.uppercased():
                let brick = brick as? VibrationBrick
                mappedBrick.name = brick?.name
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.durationInSeconds])
            // MARK: Look Bricks
            case kSetBackgroundBrick.uppercased():
                let brick = brick as? SetBackgroundBrick
                mappedBrick.name = brick?.name
                mappedBrick.lookReference = resolveLook(object: object, look: brick?.look).1
            case kSetLookBrick.uppercased():
                let brick = brick as? SetLookBrick
                mappedBrick.name = brick?.name
                mappedBrick.lookReference = resolveLook(object: object, look: brick?.look).1
            case kNextLookBrick.uppercased():
                let brick = brick as? NextLookBrick
                mappedBrick.name = brick?.name
            case kPreviousLookBrick.uppercased():
                let brick = brick as? PreviousLookBrick
                mappedBrick.name = brick?.name
            case kSetSizeToBrick.uppercased():
                let brick = brick as? SetSizeToBrick
                mappedBrick.name = brick?.name
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.size])
            case kChangeSizeByNBrick.uppercased():
                let brick = brick as? ChangeSizeByNBrick
                mappedBrick.name = brick?.name
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.size])
            case kShowBrick.uppercased():
                let brick = brick as? ShowBrick
                mappedBrick.name = brick?.name
            case kHideBrick.uppercased():
                let brick = brick as? HideBrick
                mappedBrick.name = brick?.name
            case kSetTransparencyBrick.uppercased():
                let brick = brick as? SetTransparencyBrick
                mappedBrick.name = brick?.name
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.transparency])
            case kChangeTransparencyByNBrick.uppercased():
                let brick = brick as? ChangeTransparencyByNBrick
                mappedBrick.name = brick?.name
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.changeTransparency])
            case kSetBrightnessBrick.uppercased():
                let brick = brick as? SetBrightnessBrick
                mappedBrick.name = brick?.name
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.brightness])
            case kChangeBrightnessByNBrick.uppercased():
                let brick = brick as? ChangeBrightnessByNBrick
                mappedBrick.name = brick?.name
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.changeBrightness])
            case kSetColorBrick.uppercased():
                let brick = brick as? SetColorBrick
                mappedBrick.name = brick?.name
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.color])
            case kChangeColorByNBrick.uppercased():
                let brick = brick as? ChangeColorByNBrick
                mappedBrick.name = brick?.name
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.changeColor])
            case kClearGraphicEffectBrick.uppercased():
                let brick = brick as? ClearGraphicEffectBrick
                mappedBrick.name = brick?.name
            case kFlashBrick.uppercased():
                let brick = brick as? FlashBrick
                mappedBrick.name = brick?.name
                mappedBrick.spinnerSelectionID = String(brick?.flashChoice ?? 0)
            case kCameraBrick.uppercased():
                let brick = brick as? CameraBrick
                mappedBrick.name = brick?.name
                mappedBrick.spinnerSelectionID = String(brick?.cameraChoice ?? 0)
            case kChooseCameraBrick.uppercased():
                let brick = brick as? ChooseCameraBrick
                mappedBrick.name = brick?.name
                mappedBrick.spinnerSelectionID = String(brick?.cameraPosition ?? 0)
            case kThinkBubbleBrick.uppercased():
                let brick = brick as? ThinkBubbleBrick
                mappedBrick.name = brick?.name
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.formula])
            case kThinkForBubbleBrick.uppercased():
                let brick = brick as? ThinkForBubbleBrick
                mappedBrick.name = brick?.name
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.stringFormula])
                mappedBrick.formulaList = mapFormulaList(formulas: [brick?.intFormula])
            // MARK: Sound Bricks
            case kPlaySoundBrick.uppercased():
                let brick = brick as? PlaySoundBrick
                mappedBrick.name = brick?.name
                mappedBrick.sound = resolveSound(object: object, sound: brick?.sound).0
                mappedBrick.soundReference = resolveSound(object: object, sound: brick?.sound).1
            case kStopAllSoundsBrick.uppercased():
                let brick = brick as? StopAllSoundsBrick
                mappedBrick.name = brick?.name
            case kSetVolumeToBrick.uppercased():
                let brick = brick as? SetVolumeToBrick
                mappedBrick.name = brick?.name
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.volume])
            case kChangeVolumeByNBrick.uppercased():
                let brick = brick as? ChangeVolumeByNBrick
                mappedBrick.name = brick?.name
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.volume])
            case kSpeakBrick.uppercased():
                let brick = brick as? SpeakBrick
                mappedBrick.name = brick?.name
                mappedBrick.noteMessage = brick?.text
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.formula])
            case kSpeakAndWaitBrick.uppercased():
                let brick = brick as? SpeakAndWaitBrick
                mappedBrick.name = brick?.name
                mappedBrick.noteMessage = brick?.text
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.formula])
            // MARK: Variable Bricks
            case kSetVariableBrick.uppercased():
                let brick = brick as? SetVariableBrick
                mappedBrick.name = brick?.name
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.variableFormula])
                let uVar = mapUserVariableWithLocalCheck(project: project, userVariable: brick?.userVariable, object: object)
                mappedBrick.userVariable = uVar?.value
                mappedBrick.userVariableReference = uVar?.reference
            case kChangeVariableBrick.uppercased():
                let brick = brick as? ChangeVariableBrick
                mappedBrick.name = brick?.name
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.variableFormula])
                let uVar = mapUserVariableWithLocalCheck(project: project, userVariable: brick?.userVariable, object: object)
                mappedBrick.userVariable = uVar?.value
                mappedBrick.userVariableReference = uVar?.reference
            case kShowTextBrick.uppercased():
                let brick = brick as? ShowTextBrick
                mappedBrick.name = brick?.name
                mappedBrick.xPosition = mapFormula(formula: brick?.xFormula)
                mappedBrick.yPosition = mapFormula(formula: brick?.yFormula)
                let uVar = mapUserVariableWithLocalCheck(project: project, userVariable: brick?.userVariable, object: object)
                mappedBrick.userVariable = uVar?.value
                mappedBrick.userVariableReference = uVar?.reference
            case kHideTextBrick.uppercased():
                let brick = brick as? HideTextBrick
                mappedBrick.name = brick?.name
                let uVar = mapUserVariableWithLocalCheck(project: project, userVariable: brick?.userVariable, object: object)
                mappedBrick.userVariable = uVar?.value
                mappedBrick.userVariableReference = uVar?.reference
            case kAddItemToUserListBrick.uppercased():
                let brick = brick as? AddItemToUserListBrick
                mappedBrick.name = brick?.name
                mappedBrick.formulaList = mapFormulaList(formulas: [brick?.listFormula])
                let uVar = mapUserVariableWithLocalCheck(project: project, userVariable: brick?.userList, object: object)
                mappedBrick.userList = uVar?.value
                mappedBrick.userVariableReference = uVar?.reference
            case kDeleteItemOfUserListBrick.uppercased():
                let brick = brick as? DeleteItemOfUserListBrick
                mappedBrick.name = brick?.name
                mappedBrick.formulaList = mapFormulaList(formulas: [brick?.listFormula])
                let uVar = mapUserVariableWithLocalCheck(project: project, userVariable: brick?.userList, object: object)
                mappedBrick.userList = uVar?.value
                mappedBrick.userVariableReference = uVar?.reference
            case kInsertItemIntoUserListBrick.uppercased():
                let brick = brick as? InsertItemIntoUserListBrick
                mappedBrick.name = brick?.name
                mappedBrick.formulaList = mapFormulaList(formulas: [brick?.elementFormula])
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.index])
                let uVar = mapUserVariableWithLocalCheck(project: project, userVariable: brick?.userList, object: object)
                mappedBrick.userList = uVar?.value
                mappedBrick.userVariableReference = uVar?.reference
            case kReplaceItemInUserListBrick.uppercased():
                let brick = brick as? ReplaceItemInUserListBrick
                mappedBrick.name = brick?.name
                mappedBrick.formulaList = mapFormulaList(formulas: [brick?.elementFormula])
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.index])
                let uVar = mapUserVariableWithLocalCheck(project: project, userVariable: brick?.userList, object: object)
                mappedBrick.userList = uVar?.value
                mappedBrick.userVariableReference = uVar?.reference
            // MARK: Alternative Bricks
            case kComeToFrontBrick.uppercased():
                let brick = brick as? ComeToFrontBrick
                mappedBrick.name = brick?.name
            case kGoNStepsBackBrick.uppercased():
                let brick = brick as? GoNStepsBackBrick
                mappedBrick.name = brick?.name
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.steps])
            case kSayBubbleBrick.uppercased():
                let brick = brick as? SayBubbleBrick
                mappedBrick.name = brick?.name
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.formula])
            case kSayForBubbleBrick.uppercased():
                let brick = brick as? SayForBubbleBrick
                mappedBrick.name = brick?.name
                mappedBrick.formulaTree = mapFormulaList(formulas: [brick?.stringFormula])
                mappedBrick.formulaList = mapFormulaList(formulas: [brick?.intFormula])
            default:
                print("Error at Serialization Mapping!")
            }

            mappedBrickList.append(mappedBrick)
            CBXMLMappingFromObjc.currentSerializationPosition.2 += 1
        }

        return CBBrickList(brick: mappedBrickList)
    }

    private static func mapFormulaList(formulas: [Formula?]) -> CBFormulaList? {
        var mappedFormulas = [CBFormula]()

        for formula in formulas {
            if let mappedFormula = mapFormula(formula: formula) {
                mappedFormulas.append(mappedFormula)
            }
        }

        return CBFormulaList(formula: mappedFormulas)
    }

    private static func mapFormula(formula: Formula?) -> CBFormula? {
        guard let formula = formula else { return nil }
        guard let parentElement = formula.formulaTree else { return nil }

        let type = parentElement.string(for: parentElement.type)
        let value = parentElement.value
        let category = "" // TODO???
        let left = mapFormulaChild(formulaElement: parentElement.leftChild)
        let right = mapFormulaChild(formulaElement: parentElement.rightChild)

        let mappedFormula = CBFormula(type: type, value: value, category: category, leftChild: left, rightChild: right)

        return mappedFormula
    }

    private static func mapFormulaChild(formulaElement: FormulaElement?) -> CBLRChild? {
        guard let formulaElement = formulaElement else { return nil }

        var mappedChild = CBLRChild()
        mappedChild.type = formulaElement.string(for: formulaElement.type)
        mappedChild.value = formulaElement.value
        mappedChild.leftChild = [mapFormulaChild(formulaElement: formulaElement.leftChild)]
        mappedChild.rightChild = [mapFormulaChild(formulaElement: formulaElement.rightChild)]

        return mappedChild
    }

    private static func mapUserVariableWithLocalCheck(project: Project, userVariable: UserVariable?, object: SpriteObject) -> CBUserVariable? {
        guard let userVariable = userVariable else { return nil }

        if globalVariableList.contains(where: { $0.0 == userVariable.name }) == false {
            for (index, element) in CBXMLMappingFromObjc.localVariableList.enumerated() where element.0 == object {
                if CBXMLMappingFromObjc.localVariableList[index].1.contains(where: { $0.contains(where: { $0.key == userVariable }) }) == false {
                    CBXMLMappingFromObjc.localVariableList[index].1.append([userVariable: CBXMLMappingFromObjc.currentSerializationPosition])
                }
                return mapUserVariable(project: project, userVariable: userVariable)
            }
            CBXMLMappingFromObjc.localVariableList.append((object, [[userVariable: CBXMLMappingFromObjc.currentSerializationPosition]]))
        }

        return mapUserVariable(project: project, userVariable: userVariable)
    }

    private static func mapUserVariable(project: Project, userVariable: UserVariable?) -> CBUserVariable? {
        guard let userVariable = userVariable else { return nil }

        if CBXMLMappingFromObjc.userVariableList.contains(where: { $0.0 == userVariable }) == false {
            CBXMLMappingFromObjc.userVariableList.append((userVariable, CBXMLMappingFromObjc.currentSerializationPosition))
            return(CBUserVariable(value: userVariable.name, reference: nil))
        }

        return CBUserVariable(value: nil, reference: resolveUserVariablePath(project: project, userVariable: userVariable))
    }

    private static func resolveUserVariablePath(project: Project, userVariable: UserVariable?) -> String? {
        let currentObjectPos = CBXMLMappingFromObjc.currentSerializationPosition.0
        let currentScriptPos = CBXMLMappingFromObjc.currentSerializationPosition.1

        if let referencedUserVariable = CBXMLMappingFromObjc.userVariableList.first(where: { $0.0 == userVariable }) {
            let referencedPosition = referencedUserVariable.1

            if referencedPosition.0 == currentObjectPos {
                if referencedPosition.1 == currentScriptPos {
                    return "../../" + (referencedPosition.2 == 0 ? "brick/" : "brick[\(referencedPosition.2 + 1)]/") + "userVariable"
                } else {
                    let scrString = referencedPosition.1 == 0 ? "script/" : "script[\(referencedPosition.1 + 1)]/"
                    let brString = referencedPosition.2 == 0 ? "brick/" : "brick[\(referencedPosition.2 + 1)]/"
                    return "../../../.." + scrString + "brickList/" + brString + "userVariable"
                }
            } else {
                let objString = referencedPosition.0 == 0 ? "object/" : "object[\(referencedPosition.0 + 1)]/"
                let scrString = referencedPosition.1 == 0 ? "script/" : "script[\(referencedPosition.1 + 1)]/"
                let brString = referencedPosition.2 == 0 ? "brick/" : "brick[\(referencedPosition.2 + 1)]/"
                return "../../../../../../" + objString + "scriptList/" + scrString + "brickList/" + brString + "userVariable"
            }
        }

        return nil
    }

    private static func mapData(project: Project) -> CBProjectData {
        var mappedData = CBProjectData()

        mappedData.objectVariableList = mapObjectVariableList(project: project)
        mappedData.objectListOfList = mapObjectListOfLists(project: project)
        // TODO: map userBrickVariableList

        return mappedData
    }

    private static func mapObjectVariableList(project: Project) -> CBObjectVariableList {

        var mappedEntries = [CBObjectVariableEntry]()

        for index in 0..<project.variables.objectVariableList.count() {
            mappedEntries.append(mapObjectVariableListEntry(project: project, referencedIndex: index))
        }

        return CBObjectVariableList(entry: mappedEntries)
    }

    private static func mapObjectListOfLists(project: Project) -> CBObjectListofList {

        var mappedEntries = [CBObjectListOfListEntry]()

        for index in 0..<project.variables.objectListOfLists.count() {
            mappedEntries.append(mapObjectListOfListsEntry(project: project, referencedIndex: index))
        }

        return CBObjectListofList(entry: mappedEntries)
    }

    private static func mapObjectVariableListEntry(project: Project, referencedIndex: UInt) -> CBObjectVariableEntry {
        let referencedObject = project.variables.objectVariableList.key(at: referencedIndex)
        let referencedVariableList = project.variables.objectVariableList.object(at: referencedIndex)
        let spriteObject = referencedObject as? SpriteObject
        let userVariableList = referencedVariableList as? [UserVariable]

        let object = resolveObjectPath(project: project, object: spriteObject)
        let list = mapObjectVariableListEntryList(project: project, list: userVariableList, object: spriteObject, objectPath: object)

        return CBObjectVariableEntry(object: object, list: list)
    }

    private static func mapObjectListOfListsEntry(project: Project, referencedIndex: UInt) -> CBObjectListOfListEntry {
        let referencedObject = project.variables.objectListOfLists.key(at: referencedIndex)
        let referencedVariableList = project.variables.objectListOfLists.object(at: referencedIndex)
        let spriteObject = referencedObject as? SpriteObject
        let userVariableList = referencedVariableList as? [UserVariable]

        let object = resolveObjectPath(project: project, object: spriteObject)
        let list = mapObjectVariableListEntryList(project: project, list: userVariableList, object: spriteObject, objectPath: object)

        return CBObjectListOfListEntry(object: object, list: list)
    }

    private static func resolveObjectPath(project: Project, object: SpriteObject?) -> String? {
        guard let object = object else { return nil }

        if let referencedUserVariable = CBXMLMappingFromObjc.objectList.first(where: { $0.0 == object }) {
            let referencedPosition = referencedUserVariable.1
            return "../../../../objectList/" + (referencedPosition.0 == 0 ? "object" : "object[\(referencedPosition.0 + 1)]")
        }

        return nil
    }

    private static func mapObjectVariableListEntryList(project: Project, list: [UserVariable]?, object: SpriteObject?, objectPath: String?) -> [CBUserVariable]? {
        guard let list = list else { return nil }
        guard let objectPath = objectPath else { return nil }
        var mappedUserVariables = [CBUserVariable]()

        for userVariable in list {
            if CBXMLMappingFromObjc.globalVariableList.contains(where: { $0.0 == userVariable.name }) == false {
                if let referencedDictionary = CBXMLMappingFromObjc.localVariableList.first(where: { $0.0 == object }) {
                    if let referencedArray = referencedDictionary.1.first(where: { $0[userVariable] != nil }) {
                        if let referencedUserVariablePosition = referencedArray.first(where: { $0.key == userVariable }) {
                            let scrString = referencedUserVariablePosition.1.1 == 0 ? "script/" : "script[\(referencedUserVariablePosition.1.1 + 1)]/"
                            let brString = referencedUserVariablePosition.1.2 == 0 ? "brick/" : "brick[\(referencedUserVariablePosition.1.2 + 1)]/"
                            let referenceString = "../" + objectPath + "/scriptList/" + scrString + "brickList/" + brString + "userVariable"
                            mappedUserVariables.append(CBUserVariable(value: "userVariable", reference: referenceString))
                        }
                    }
                }
            } else {
                if let referencedUserVariable = CBXMLMappingFromObjc.userVariableList.first(where: { $0.0 == userVariable }) {
                    let referencedPosition = referencedUserVariable.1
                    let objString = referencedPosition.0 == 0 ? "object/" : "object[\(referencedPosition.0 + 1)]/"
                    let scrString = referencedPosition.1 == 0 ? "script/" : "script[\(referencedPosition.1 + 1)]/"
                    let brString = referencedPosition.2 == 0 ? "brick/" : "brick[\(referencedPosition.2 + 1)]/"
                    let referenceString = "../../../../../objectList/" + objString + "scriptList/" + scrString + "brickList/" + brString + "userVariable"
                    mappedUserVariables.append(CBUserVariable(value: "userVariable", reference: referenceString))
                }
            }
        }

        return mappedUserVariables
    }

    // MARK: - Map ProgramVariableList
    private static func mapProgramVariableList(project: Project) -> CBProgramVariableList {
        var mappedProgramVariables = [CBUserProgramVariable]()

        for variable in globalVariableList where variable.1 == false {
            for v in CBXMLMappingFromObjc.userVariableList where v.0?.name == variable.0 {
                let referencedPosition = v.1
                let objString = referencedPosition.0 == 0 ? "object/" : "object[\(referencedPosition.0 + 1)]/"
                let scrString = referencedPosition.1 == 0 ? "script/" : "script[\(referencedPosition.1 + 1)]/"
                let brString = referencedPosition.2 == 0 ? "brick/" : "brick[\(referencedPosition.2 + 1)]/"
                let referenceString = "../../../objectList/" + objString + "scriptList/" + scrString + "brickList/" + brString + "userVariable"
                mappedProgramVariables.append(CBUserProgramVariable(reference: referenceString))
            }
        }

        return CBProgramVariableList(userVariable: mappedProgramVariables)
    }

    // MARK: - Map ProgramListOfLists
    private static func mapProgramListOfLists(project: Project) -> CBProgramListOfLists {
        var mappedProgramVariables = [CBProgramList]()

        for variable in globalVariableList where variable.1 == true {
            for v in CBXMLMappingFromObjc.userVariableList where v.0?.name == variable.0 {
                let referencedPosition = v.1
                let objString = referencedPosition.0 == 0 ? "object/" : "object[\(referencedPosition.0 + 1)]/"
                let scrString = referencedPosition.1 == 0 ? "script/" : "script[\(referencedPosition.1 + 1)]/"
                let brString = referencedPosition.2 == 0 ? "brick/" : "brick[\(referencedPosition.2 + 1)]/"
                let referenceString = "../../../objectList/" + objString + "scriptList/" + scrString + "brickList/" + brString + "userVariable"
                mappedProgramVariables.append(CBProgramList(reference: referenceString))
            }
        }

        return CBProgramListOfLists(list: mappedProgramVariables)
    }
}
