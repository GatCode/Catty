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

import SWXMLHash

struct CBProject: XMLIndexerDeserializable, Equatable {
    let header: CBHeader?
    let scenes: [CBProjectScene]?
    let programVariableList: CBProgramVariableList?
    let programListOfLists: CBProgramListOfLists?

    static func deserialize(_ node: XMLIndexer) throws -> CBProject {

        var tmpScenes: [CBProjectScene]?
        var tmpProgramVariableList: CBProgramVariableList?
        tmpScenes = try node["scenes"].value()
        tmpProgramVariableList = try node["programVariableList"].value()

        if tmpScenes == nil {
            tmpScenes = [CBProjectScene]()
            var objectList: CBObjectList?
            var objectVariableList: CBObjectVariableList?

            objectList = try node["objectList"].value()
            objectVariableList = try node["variables"]["objectVariableList"].value()
            if objectVariableList == nil {
                objectVariableList = try node["data"]["objectVariableList"].value()
            }

            let data = CBProjectData(objectListOfList: nil, objectVariableList: objectVariableList, userBrickVariableList: nil)

            tmpScenes!.append(CBProjectScene(name: nil, objectList: objectList, data: data, originalWidth: nil, originalHeight: nil))

            tmpProgramVariableList = try node["variables"]["programVariableList"].value()

            if tmpProgramVariableList == nil {
                tmpProgramVariableList = try node["data"]["programVariableList"].value()
            }
        }

        return try CBProject(
            header: node["header"].value(),
            scenes: tmpScenes,
            programVariableList: tmpProgramVariableList,
            programListOfLists: node["programListOfLists"].value()
        )
    }

    static func == (lhs: CBProject, rhs: CBProject) -> Bool {
        return
            lhs.header == rhs.header &&
            lhs.scenes == rhs.scenes
    }
}

@objc class CBProjectObjc: NSObject {
    @objc var header = CBHeaderObjc()

    init(project: CBProject?) {
        header = CBHeaderObjc(header: project?.header)
    }
}

@objc class CBHeaderObjc: NSObject {
    @objc var applicationBuildName: String?
    @objc var applicationBuildNumber: String?
    @objc var applicationName: String?
    @objc var applicationVersion: String?
    @objc var catrobatLanguageVersion: String?
    @objc var dateTimeUpload: String?
    @objc var descr: String?
    @objc var deviceName: String?
    @objc var isCastProject: String?
    @objc var landscapeMode: String?
    @objc var mediaLicense: String?
    @objc var platform: String?
    @objc var platformVersion: String?
    @objc var programLicense: String?
    @objc var programName: String?
    @objc var remixOf: String?
    @objc var scenesEnabled: String?
    @objc var screenHeight: String?
    @objc var screenMode: String?
    @objc var screenWidth: String?
    @objc var tags: String?
    @objc var url: String?
    @objc var userHandle: String?
    @objc var programID: String?

    override init() {}
    init(header: CBHeader?) {
        applicationBuildName = header?.applicationBuildName
        applicationBuildNumber = header?.applicationBuildNumber
        applicationName = header?.applicationName
        applicationVersion = header?.applicationVersion
        catrobatLanguageVersion = header?.catrobatLanguageVersion
        dateTimeUpload = header?.dateTimeUpload
        descr = header?.description
        deviceName = header?.deviceName
        isCastProject = header?.isCastProject
        landscapeMode = header?.landscapeMode
        mediaLicense = header?.mediaLicense
        platform = header?.platform
        platformVersion = header?.platformVersion
        programLicense = header?.programLicense
        programName = header?.programName
        remixOf = header?.remixOf
        scenesEnabled = header?.scenesEnabled
        screenHeight = header?.screenHeight
        screenMode = header?.screenMode
        screenWidth = header?.screenWidth
        tags = header?.tags
        url = header?.url
        userHandle = header?.userHandle
        programID = header?.programID
    }
}
