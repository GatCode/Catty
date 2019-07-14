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

    func addHeaderTo(program: AEXMLElement, data: CBHeader?) {
        guard let data = data else { return }
        let header = program.addChild(name: "header")

        header.addChild(name: "applicationBuildName", value: data.applicationBuildName)
        header.addChild(name: "applicationBuildNumber", value: data.applicationBuildNumber)
        header.addChild(name: "applicationName", value: data.applicationName)
        header.addChild(name: "applicationVersion", value: data.applicationVersion)
        header.addChild(name: "catrobatLanguageVersion", value: "0.991") // TODO
        header.addChild(name: "dateTimeUpload", value: data.dateTimeUpload)
        header.addChild(name: "description", value: data.description)
        header.addChild(name: "deviceName", value: data.deviceName)

        if CBXMLSerializer2.serializeInCBL991 == false {
            header.addChild(name: "isCastProject", value: data.isCastProject)
        }

        header.addChild(name: "landscapeMode", value: data.landscapeMode)
        header.addChild(name: "mediaLicense", value: data.mediaLicense)
        header.addChild(name: "platform", value: data.platform)
        header.addChild(name: "platformVersion", value: data.platformVersion)
        header.addChild(name: "programLicense", value: data.programLicense)
        header.addChild(name: "programName", value: data.programName)
        header.addChild(name: "remixOf", value: data.remixOf)

        if CBXMLSerializer2.serializeInCBL991 == false {
            header.addChild(name: "scenesEnabled", value: data.scenesEnabled)
        }

        header.addChild(name: "screenHeight", value: data.screenHeight)
        header.addChild(name: "screenMode", value: data.screenMode)
        header.addChild(name: "screenWidth", value: data.screenWidth)
        header.addChild(name: "tags", value: data.tags)
        header.addChild(name: "url", value: data.url)
        header.addChild(name: "userHandle", value: data.userHandle)
    }
}
