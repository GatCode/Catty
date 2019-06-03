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

import AEXML

extension CBXMLSerializer2 {

    // MARK: - Serialize Scenes
    func addScenesTo(program: AEXMLElement, data: [CBProjectScene]?) {
        guard let data = data else { return }

        let scenes = program.addChild(name: "scenes")

        for scene in data {
            let currentScene = scenes.addChild(name: "scene")

            currentScene.addChild(name: "name", value: scene.name)

            if let objectList = scene.objectList?.object {
                addObjectListTo(scene: currentScene, data: objectList)
            }
        }
    }

    // MARK: - Serialize ObjectList
    func addObjectListTo(scene: AEXMLElement, data: [CBObject]?) {
        guard let data = data else { return }

        let objectList = scene.addChild(name: "objectList")
        addObjectsTo(objectList: objectList, data: data)
    }

    func addObjectsTo(objectList: AEXMLElement, data: [CBObject]?) {
        guard let data = data else { return }

        for object in data {
            let currentObject = objectList.addChild(name: "object", attributes: ["type": object.type ?? "", "name": object.name ?? ""])

            addLookListTo(object: currentObject, data: object.lookList)
            addSoundListTo(object: currentObject, data: object.soundList)
            addScriptListTo(object: currentObject, data: object.scriptList)
            addUserBricksTo(object: currentObject, data: object.userBricks)
            addNfcTagListTo(object: currentObject, data: object.nfcTagList)
        }
    }

    // MARK: - Serialize LookList
    func addLookListTo(object: AEXMLElement, data: CBLookList?) {
        guard let data = data else { return }

        let lookList = object.addChild(name: "lookList")
        addLooksTo(lookList: lookList, data: data.look)
    }

    func addLooksTo(lookList: AEXMLElement, data: [CBLook]?) {
        guard let data = data else { return }

        for look in data {
            let currentLook = lookList.addChild(name: "look", attributes: ["name": look.name ?? ""])

            currentLook.addChild(name: "fileName", value: look.fileName)
        }
    }

    // MARK: - Serialize SoundList
    func addSoundListTo(object: AEXMLElement, data: CBSoundList?) {
        guard let data = data else { return }

        let soundList = object.addChild(name: "soundList")
        addSoundsTo(soundList: soundList, data: data.sound)
    }

    func addSoundsTo(soundList: AEXMLElement, data: [CBSound]?) {
        guard let data = data else { return }

        for sound in data {
            let currentSound = soundList.addChild(name: "sound")

            currentSound.addChild(name: "fileName", value: sound.fileName)
            currentSound.addChild(name: "name", value: sound.name)
        }
    }

    // MARK: - Serialize ScriptList
    func addScriptListTo(object: AEXMLElement, data: CBScriptList?) {
        guard let data = data else { return }

        let scriptList = object.addChild(name: "scriptList")
        addScriptsTo(scriptList: scriptList, data: data.script)
    }

    func addScriptsTo(scriptList: AEXMLElement, data: [CBScript]?) {
        guard let data = data else { return }

        for script in data {
            let currentScript = scriptList.addChild(name: "script", attributes: ["type": script.type ?? ""])

            addBrickListTo(script: currentScript, data: script.brickList)

            if let msg = script.commentedOut {
                currentScript.addChild(name: "commentedOut", value: msg)
            }

            if let msg = script.isUserScript {
                currentScript.addChild(name: "isUserScript", value: msg)
            }

            if let msg = script.receivedMessage {
                currentScript.addChild(name: "receivedMessage", value: msg)
            }

            if let msg = script.action {
                currentScript.addChild(name: "action", value: msg)
            }
        }
    }

    // MARK: - Serialize BrickList
    func addBrickListTo(script: AEXMLElement, data: CBBrickList?) {
        guard let data = data else { return }

        let brickList = script.addChild(name: "brickList")
        addBricksTo(brickList: brickList, data: data.brick)
    }

    func addBricksTo(brickList: AEXMLElement, data: [CBBrick]?) {
        guard let data = data else { return }

        for brick in data {
            let currentBrick = brickList.addChild(name: "brick", attributes: ["type": brick.name ?? ""])

            if let msg = brick.commentedOut {
                currentBrick.addChild(name: "commentedOut", value: msg)
            }

            if let msg = brick.formulaList {
                addFormulaListTo(brick: currentBrick, data: msg)
            }

            if let msg = brick.lookReference {
                currentBrick.addChild(name: "look", attributes: ["reference": msg])
            }

            if let msg = brick.userVariable {
                if let varRef = brick.userVariableReference {
                    currentBrick.addChild(name: "userVariable", value: msg, attributes: ["reference": varRef])
                } else {
                    currentBrick.addChild(name: "userVariable", value: msg)
                }
            }

            if let msg = brick.broadcastMessage {
                currentBrick.addChild(name: "broadcastMessage", value: msg)
            }
        }
    }

    // MARK: - Serialize FormulaList
    func addFormulaListTo(brick: AEXMLElement, data: CBFormulaList?) {
        guard let data = data else { return }

        let formulaList = brick.addChild(name: "formulaList")
        addFormulasTo(formulaList: formulaList, data: data.formula)
    }

    func addFormulasTo(formulaList: AEXMLElement, data: [CBFormula]?) {
        guard let data = data else { return }

        for formula in data {
            let currentFormula = formulaList.addChild(name: "formula", attributes: ["category": formula.category ?? ""])

            if let msg = formula.leftChild {
                addChildTo(formula: currentFormula, data: msg, isLeftChild: true)
            }

            if let msg = formula.rightChild {
                addChildTo(formula: currentFormula, data: msg, isLeftChild: false)
            }

            if let msg = formula.type {
                currentFormula.addChild(name: "type", value: msg)
            }

            if let msg = formula.value {
                currentFormula.addChild(name: "value", value: msg)
            }
        }
    }

    func addChildTo(formula: AEXMLElement, data: CBLRChild?, isLeftChild: Bool) {
        guard let data = data else { return }

        let child = formula.addChild(name: isLeftChild ? "leftChild" : "rightChild")

        // children of children
        if let leftChildOfChild = data.leftChild {
            addChildTo(child: child, data: leftChildOfChild, isLeftChild: true)
        }
        if let rightChildOfChild = data.rightChild {
            addChildTo(child: child, data: rightChildOfChild, isLeftChild: false)
        }

        child.addChild(name: "type", value: data.type)
        child.addChild(name: "value", value: data.value)
    }

    func addChildTo(child: AEXMLElement, data: CBLRChildOfChild?, isLeftChild: Bool) {
        guard let data = data else { return }

        let child = child.addChild(name: isLeftChild ? "leftChild" : "rightChild")

        // children of second level children
        if let leftChildOfChild = data.leftChild {
            addChildTo(secondLevelChild: child, data: leftChildOfChild, isLeftChild: true)
        }
        if let rightChildOfChild = data.rightChild {
            addChildTo(secondLevelChild: child, data: rightChildOfChild, isLeftChild: false)
        }

        child.addChild(name: "type", value: data.type)
        child.addChild(name: "value", value: data.value)
    }

    func addChildTo(secondLevelChild: AEXMLElement, data: CBLRChildOfSecondLevelChild?, isLeftChild: Bool) {
        guard let data = data else { return }

        let child = secondLevelChild.addChild(name: isLeftChild ? "leftChild" : "rightChild")

        child.addChild(name: "type", value: data.type)
        child.addChild(name: "value", value: data.value)
    }

    // MARK: - Serialize UserBricks
    func addUserBricksTo(object: AEXMLElement, data: CBUserBricks?) {
        guard let data = data else { return }

        let userBricks = object.addChild(name: "userBricks")
        addUserBricksTo(userBricks: userBricks, data: data.userBrick)
    }

    func addUserBricksTo(userBricks: AEXMLElement, data: [CBUserBrick]?) {
        guard let data = data else { return }

        for brick in data {
            // TODO: check it!
            userBricks.addChild(name: "name", value: brick.name)
        }
    }

    // MARK: - Serialize NfcTagList
    func addNfcTagListTo(object: AEXMLElement, data: CBNfcTagList?) {
        guard let data = data else { return }

        let nfcTagList = object.addChild(name: "nfcTagList")
        addNfcTagsTo(nfcTagList: nfcTagList, data: data.nfcTag)
    }

    func addNfcTagsTo(nfcTagList: AEXMLElement, data: [CBNfcTag]?) {
        guard let data = data else { return }

        for tag in data {
            // TODO: check it!
            nfcTagList.addChild(name: "name", value: tag.name)
            nfcTagList.addChild(name: "uid", value: tag.uid)
        }
    }
}
