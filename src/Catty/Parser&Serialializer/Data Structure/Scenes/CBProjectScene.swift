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
import SWXMLHash

struct CBProjectScene: XMLIndexerDeserializable, Equatable {
    var name: String?
    var objectList: CBObjectList?
    var data: CBProjectData?
    var originalWidth: String?
    var originalHeight: String?

    init(name: String? = nil,
         objectList: CBObjectList? = nil,
         data: CBProjectData? = nil,
         originalWidth: String? = nil,
         originalHeight: String? = nil) {
        self.name = name
        self.objectList = objectList
        self.data = data
        self.originalWidth = originalWidth
        self.originalHeight = originalHeight
    }

    static func deserialize(_ node: XMLIndexer) throws -> CBProjectScene {
        return try CBProjectScene(
            name: node["scene"]["name"].value(),
            objectList: node["scene"]["objectList"].value(),
            data: node["scene"]["data"].value(),
            originalWidth: node["scene"]["originalWidth"].value(),
            originalHeight: node["scene"]["originalHeight"].value()
        )
    }

    static func == (lhs: CBProjectScene, rhs: CBProjectScene) -> Bool {
        return
            lhs.objectList == rhs.objectList
    }
}
