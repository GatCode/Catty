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

extension CBXMLMapping {

    static func mapHeaderToHeader(input: CBHeader?) -> Header {

        // TODO: dateTimeUpload currently ignored
        let header = Header()
        header.applicationBuildName = input?.applicationBuildName
        header.applicationBuildNumber = input?.applicationBuildNumber
        header.applicationName = input?.applicationName
        header.applicationVersion = input?.applicationVersion
        header.catrobatLanguageVersion = input?.catrobatLanguageVersion
        header.programDescription = input?.description
        header.deviceName = input?.deviceName
        header.landscapeMode = input?.landscapeMode?.bool ?? false
        header.mediaLicense = input?.mediaLicense
        header.platform = input?.platform
        header.platformVersion = input?.platformVersion
        header.programLicense = input?.programLicense
        header.programName = input?.programName
        header.remixOf = input?.remixOf

        var screenHeight: NSNumber?
        if let tmp = Int(input?.screenHeight ?? "") {
            screenHeight = NSNumber(value: tmp)
        }
        header.screenHeight = screenHeight

        header.screenMode = input?.screenMode

        var screenWidth: NSNumber?
        if let tmp = Int(input?.screenWidth ?? "") {
            screenWidth = NSNumber(value: tmp)
        }
        header.screenWidth = screenWidth

        header.tags = input?.tags
        header.url = input?.url
        header.userHandle = input?.userHandle
        header.programID = input?.programID

        return header
    }
}

extension String {
    var bool: Bool? {
        switch self.lowercased() {
        case "true", "1":
            return true
        case "false", "0":
            return false
        default:
            return nil
        }
    }
}
