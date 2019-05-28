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

struct CBObject: XMLIndexerDeserializable, Equatable {
    let name: String?
    let lookList: CBLookList?
    let soundList: CBSoundList?
    let scriptList: CBScriptList?
    let userBricks: CBUserBricks?
    let nfcTagList: CBNfcTagList?

    static func deserialize(_ node: XMLIndexer) throws -> CBObject {

        var tmpName: String?
        tmpName = node.value(ofAttribute: "name")
        if tmpName == nil {
            tmpName = try node["name"].value()
        }

        return try CBObject(
            name: tmpName,
            lookList: node["lookList"].value(),
            soundList: node["soundList"].value(),
            scriptList: node["scriptList"].value(),
            userBricks: node["userBricks"].value(),
            nfcTagList: node["nfcTagList"].value()
        )
    }

    static func == (lhs: CBObject, rhs: CBObject) -> Bool {
        return
            lhs.lookList == rhs.lookList &&
            lhs.soundList == rhs.soundList
    }
}
