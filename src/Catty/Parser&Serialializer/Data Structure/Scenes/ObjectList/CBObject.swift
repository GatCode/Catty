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

struct CBObject: XMLIndexerDeserializable, Equatable {
    var name: String?
    var type: String?
    var reference: String?
    var lookList: CBLookList?
    var soundList: CBSoundList?
    var scriptList: CBScriptList?
    var userBrickList: CBUserBrickList?
    var nfcTagList: CBNfcTagList?

    init(name: String? = nil,
         type: String? = nil,
         reference: String? = nil,
         lookList: CBLookList? = nil,
         soundList: CBSoundList? = nil,
         scriptList: CBScriptList? = nil,
         userBrickList: CBUserBrickList? = nil,
         nfcTagList: CBNfcTagList? = nil) {
        self.name = name
        self.type = type
        self.reference = reference
        self.lookList = lookList
        self.soundList = soundList
        self.scriptList = scriptList
        self.userBrickList = userBrickList
        self.nfcTagList = nfcTagList
    }

    static func deserialize(_ node: XMLIndexer) throws -> CBObject {
        var tmpName: String?
        tmpName = node.value(ofAttribute: "name")
        if tmpName == nil {
            tmpName = try node["name"].value()
        }

        return try CBObject(
            name: tmpName,
            type: node.value(ofAttribute: "type"),
            reference: node.value(ofAttribute: "reference"),
            lookList: node["lookList"].value(),
            soundList: node["soundList"].value(),
            scriptList: node["scriptList"].value(),
            userBrickList: node["userBricks"].value(),
            nfcTagList: node["nfcTagList"].value()
        )
    }

    static func == (lhs: CBObject, rhs: CBObject) -> Bool {
        return
            lhs.lookList == rhs.lookList &&
            lhs.soundList == rhs.soundList
    }
}
