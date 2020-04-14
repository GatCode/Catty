/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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

class HeaderMock: Project {
    
    override init() {
        super.init()
        self.header = Header()
        self.header.applicationBuildName = "Catty"
        self.header.applicationBuildNumber = "0"
        self.header.applicationName = "Mock"
        self.header.applicationVersion = "0.01"
        self.header.catrobatLanguageVersion = "0.80"
        self.header.dateTimeUpload = DateFormatter.init().date(from: "2020-01-02 03:04:05")
        self.header.programDescription = "test description"
        self.header.deviceName = "iPhone X"
        self.header.landscapeMode = false
        self.header.mediaLicense = "http://developer.catrobat.org/ccbysa_v3"
        self.header.platform = "iOS"
        self.header.platformVersion = "13.1"
        self.header.programLicense = "http://developer.catrobat.org/agpl_v3"
        self.header.programName = "Test Project"
        self.header.remixOf = "https://pocketcode.org/details/719"
        self.header.screenHeight = NSNumber(integerLiteral: 1000)
        self.header.screenWidth = NSNumber(integerLiteral: 400)
        self.header.screenMode = ""
        self.header.tags = "one, two, three"
        self.header.url = "http://pocketcode.org/details/719"
        self.header.userHandle = "Catrobat"
        self.header.programID = "123"
    }
}
