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

class CBXMLSerializer2 {

    static let shared = CBXMLSerializer2()

    func createXMLDocument(project: CBProject) -> String {
        var options = AEXMLOptions()
        options.documentHeader.version = 1.0
        options.documentHeader.encoding = "UTF-8"
        options.documentHeader.standalone = "yes"
        let writeRequest = AEXMLDocument(options: options)

        let program = writeRequest.addChild(name: "program")

        addHeaderTo(program: program, data: project.header)
        addSettingsTo(program: program)
        addScenesTo(program: program, data: project.scenes)

        return writeRequest.xml
    }

    // MARK: - Read/Write XML File
    func writeXMLFile(filename: String, data: String) {

        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {

            let filePath = dir.appendingPathComponent(filename)

            do {
                try data.write(to: filePath, atomically: false, encoding: .utf8)
                print("XML file written to: \(dir)")
            } catch {
                print("ERROR: XML file could not be written!")
            }
        }
    }

    func readXMLFile(filename: String) -> String {

        var result = ""

        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {

            let filePath = dir.appendingPathComponent(filename)

            do {
                result = try String(contentsOf: filePath, encoding: .utf8)
            } catch {
                print("ERROR: XML file could not be written!")
            }
        }

        return result
    }

    // MARK: - Serialize Header
    private func addHeaderTo(program: AEXMLElement, data: CBHeader?) {
        guard let data = data else { return }
        let header = program.addChild(name: "header")

        header.addChild(name: "applicationBuildName", value: data.applicationBuildName)
        header.addChild(name: "applicationBuildNumber", value: data.applicationBuildNumber)
        header.addChild(name: "applicationName", value: data.applicationName)
        header.addChild(name: "applicationVersion", value: data.applicationVersion)
        header.addChild(name: "catrobatLanguageVersion", value: data.catrobatLanguageVersion)
        header.addChild(name: "dateTimeUpload", value: data.dateTimeUpload)
        header.addChild(name: "description", value: data.description)
        header.addChild(name: "deviceName", value: data.deviceName)
        header.addChild(name: "isCastProject", value: data.isCastProject)
        header.addChild(name: "landscapeMode", value: data.landscapeMode)
        header.addChild(name: "mediaLicense", value: data.mediaLicense)
        header.addChild(name: "platform", value: data.platform)
        header.addChild(name: "platformVersion", value: data.platformVersion)
        header.addChild(name: "programLicense", value: data.programLicense)
        header.addChild(name: "programName", value: data.programName)
        header.addChild(name: "remixOf", value: data.remixOf)
        header.addChild(name: "scenesEnabled", value: data.scenesEnabled)
        header.addChild(name: "screenHeight", value: data.screenHeight)
        header.addChild(name: "screenMode", value: data.screenMode)
        header.addChild(name: "screenWidth", value: data.screenWidth)
        header.addChild(name: "tags", value: data.tags)
        header.addChild(name: "url", value: data.url)
        header.addChild(name: "userHandle", value: data.userHandle)
    }

    // MARK: - Serialize Settings
    private func addSettingsTo(program: AEXMLElement) {
        let settings = program.addChild(name: "settings")
    }

    // MARK: - Serialize Scenes
    private func addScenesTo(program: AEXMLElement, data: [CBProjectScene]?) {
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
    private func addObjectListTo(scene: AEXMLElement, data: [CBObject]?) {
        guard let data = data else { return }

        let objectList = scene.addChild(name: "objectList")
        addObjectsTo(objectList: objectList, data: data)
    }

    private func addObjectsTo(objectList: AEXMLElement, data: [CBObject]?) {
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
    private func addLookListTo(object: AEXMLElement, data: CBLookList?) {
        guard let data = data else { return }

        let lookList = object.addChild(name: "lookList")
        addLooksTo(lookList: lookList, data: data.look)
    }

    private func addLooksTo(lookList: AEXMLElement, data: [CBLook]?) {
        guard let data = data else { return }

        for look in data {
            let currentLook = lookList.addChild(name: "look", attributes: ["name": look.name ?? ""])

            currentLook.addChild(name: "fileName", value: look.fileName)
        }
    }

    // MARK: - Serialize SoundList
    private func addSoundListTo(object: AEXMLElement, data: CBSoundList?) {
        guard let data = data else { return }

        let soundList = object.addChild(name: "soundList")
        addSoundsTo(soundList: soundList, data: data.sound)
    }

    private func addSoundsTo(soundList: AEXMLElement, data: [CBSound]?) {
        guard let data = data else { return }

        for sound in data {
            let currentSound = soundList.addChild(name: "sound")

            currentSound.addChild(name: "fileName", value: sound.fileName)
            currentSound.addChild(name: "name", value: sound.name)
        }
    }

    // MARK: - Serialize ScriptList
    private func addScriptListTo(object: AEXMLElement, data: CBScriptList?) {
        guard let data = data else { return }

        let scriptList = object.addChild(name: "scriptList")
        addScriptsTo(scriptList: scriptList, data: data.script)
    }

    private func addScriptsTo(scriptList: AEXMLElement, data: [CBScript]?) {
        guard let data = data else { return }

        for script in data {
            let currentScript = scriptList.addChild(name: "script", attributes: ["type": script.type ?? ""])

            //bricklist

            // TODO: add values
            currentScript.addChild(name: "commentedOut", value: "commentedOut")
            currentScript.addChild(name: "isUserScript", value: "isUserScript")
            currentScript.addChild(name: "receivedMessage", value: "receivedMessage")
        }
    }

    // MARK: - Serialize BrickList
    private func addBrickListTo(script: AEXMLElement, data: CBBrickList?) {
        guard let data = data else { return }

        let brickList = script.addChild(name: "brickList")
        addBricksTo(brickList: brickList, data: data.brick)
    }

    private func addBricksTo(brickList: AEXMLElement, data: [CBBrick]?) {
        guard let data = data else { return }

        for brick in data {
            let currentBrick = brickList.addChild(name: "brick", attributes: ["type": brick.name ?? ""])

            // TODO: add values
            currentBrick.addChild(name: "commentedOut", value: "commentedOut")
            addFormulaListTo(brick: currentBrick, data: brick.formulaList)
            currentBrick.addChild(name: "userVariable", value: "userVariable")
        }
    }

    // MARK: - Serialize FormulaList
    private func addFormulaListTo(brick: AEXMLElement, data: CBFormulaList?) {
        guard let data = data else { return }

        let formulaList = brick.addChild(name: "formulaList")
        addFormulasTo(formulaList: formulaList, data: data.formula)
    }

    private func addFormulasTo(formulaList: AEXMLElement, data: [CBFormula]?) {
        guard let data = data else { return }

        for formula in data {
            // TODO: add category
            let currentFormula = formulaList.addChild(name: "formula", attributes: ["category": "category"])

            // TODO: add rightChild
            currentFormula.addChild(name: "type", value: formula.type)
            currentFormula.addChild(name: "value", value: formula.value)
        }
    }

    // MARK: - Serialize UserBricks
    private func addUserBricksTo(object: AEXMLElement, data: CBUserBricks?) {
        guard let data = data else { return }

        let userBricks = object.addChild(name: "userBricks")
        addUserBricksTo(userBricks: userBricks, data: data.userBrick)
    }

    private func addUserBricksTo(userBricks: AEXMLElement, data: [CBUserBrick]?) {
        guard let data = data else { return }

        for brick in data {
            // TODO: check it!
            userBricks.addChild(name: "name", value: brick.name)
        }
    }

    // MARK: - Serialize NfcTagList
    private func addNfcTagListTo(object: AEXMLElement, data: CBNfcTagList?) {
        guard let data = data else { return }

        let nfcTagList = object.addChild(name: "nfcTagList")
        addNfcTagsTo(nfcTagList: nfcTagList, data: data.nfcTag)
    }

    private func addNfcTagsTo(nfcTagList: AEXMLElement, data: [CBNfcTag]?) {
        guard let data = data else { return }

        for tag in data {
            // TODO: check it!
            nfcTagList.addChild(name: "name", value: tag.name)
            nfcTagList.addChild(name: "uid", value: tag.uid)
        }
    }
}
