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

    func createXMLDocument(project: CBProject) -> String? {
        var options = AEXMLOptions()
        options.documentHeader.version = 1.0
        options.documentHeader.encoding = "UTF-8"
        options.documentHeader.standalone = "yes"
        let writeRequest = AEXMLDocument(options: options)

        let program = writeRequest.addChild(name: "program")

        addHeaderTo(program: program, data: project.header)
        addSettingsTo(program: program)
        addScenesTo(program: program, data: project.scenes)

        print(writeRequest.xml)

        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        writeXMLFileTo(filename: "file.txt", directory: dir, data: writeRequest.xml)

        return writeRequest.xml
    }

    func writeXMLFileTo(filename: String, directory: URL?, data: String) {
        guard let directory = directory else { return }
        let dataPath = directory.appendingPathComponent(data)
        try? data.write(to: dataPath, atomically: false, encoding: .utf8)
    }

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

    private func addSettingsTo(program: AEXMLElement) {
        let settings = program.addChild(name: "settings")
    }

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

    private func addObjectListTo(scene: AEXMLElement, data: [CBObject]) {
        let objectList = scene.addChild(name: "objectList")
        addObjectsTo(objectList: objectList, data: data)
    }

    private func addObjectsTo(objectList: AEXMLElement, data: [CBObject]) {
        for object in data {
            objectList.addChild(name: "object", attributes: ["type" : "helloWorld", "name" : object.name ?? ""])
        }
    }
}
