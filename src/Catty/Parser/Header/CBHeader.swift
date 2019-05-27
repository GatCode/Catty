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

struct CBHeader: XMLIndexerDeserializable, Equatable {
    let applicationBuildName: String?
    let applicationBuildNumber: String?
    let applicationName: String?
    let applicationVersion: String?
    let catrobatLanguageVersion: String?
    let dateTimeUpload: String?
    let description: String?
    let deviceName: String?
    let mediaLicense: String?
    let platform: String?
    let platformVersion: String?
    let programLicense: String?
    let programName: String?
    let remixOf: String?
    let screenHeight: String?
    let screenMode: String?
    let screenWidth: String?
    let tags: String?
    let url: String?
    let userHandle: String?

    static func deserialize(_ node: XMLIndexer) throws -> CBHeader {
        return try CBHeader(
            applicationBuildName: node["applicationBuildName"].value(),
            applicationBuildNumber: node["applicationBuildNumber"].value(),
            applicationName: node["applicationName"].value(),
            applicationVersion: node["applicationVersion"].value(),
            catrobatLanguageVersion: node["catrobatLanguageVersion"].value(),
            dateTimeUpload: node["dateTimeUpload"].value(),
            description: node["description"].value(),
            deviceName: node["deviceName"].value(),
            mediaLicense: node["mediaLicense"].value(),
            platform: node["platform"].value(),
            platformVersion: node["platformVersion"].value(),
            programLicense: node["programLicense"].value(),
            programName: node["programName"].value(),
            remixOf: node["remixOf"].value(),
            screenHeight: node["screenHeight"].value(),
            screenMode: node["screenMode"].value(),
            screenWidth: node["screenWidth"].value(),
            tags: node["tags"].value(),
            url: node["url"].value(),
            userHandle: node["userHandle"].value()
        )
    }

    static func == (lhs: CBHeader, rhs: CBHeader) -> Bool {
        return
            lhs.applicationBuildName == rhs.applicationBuildName &&
            lhs.applicationBuildNumber == rhs.applicationBuildNumber &&
            lhs.applicationName == rhs.applicationName &&
            lhs.description == rhs.description &&
            lhs.programLicense == rhs.programLicense &&
            lhs.programName == rhs.programName &&
            lhs.remixOf == rhs.remixOf &&
            lhs.screenHeight == rhs.screenHeight &&
            lhs.screenWidth == rhs.screenWidth &&
            lhs.userHandle == rhs.userHandle
    }
}
