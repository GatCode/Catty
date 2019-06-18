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

struct CBBrick: XMLIndexerDeserializable {
    let name: String?
    let type: String?
    let sound: String?
    let commentedOut: String?
    let formulaList: CBFormulaList?
    let formulaTree: CBFormulaList?
    let lookReference: String?
    let userVariable: String?
    let userVariableReference: String?
    let userList: String?
    let broadcastMessage: String?
    let noteMessage: String?
    let pointedObject: String?
    let spinnerSelectionID: String?

    static func deserialize(_ node: XMLIndexer) throws -> CBBrick {
        var userVar: String?

        userVar = try? node["userVariable"].value()
        if userVar?.isEmpty ?? true {
            userVar = try? node["userVariableName"].value()
        }

        return try CBBrick(
            name: node["name"].value(),
            type: node.value(ofAttribute: "type"),
            sound: node["sound"].value(ofAttribute: "reference"),
            commentedOut: node["commentedOut"].value(),
            formulaList: node["formulaList"].value(),
            formulaTree: node["size"]["formulaTree"].value(),
            lookReference: node["look"].value(ofAttribute: "reference"),
            userVariable: userVar,
            userVariableReference: node["userVariable"].value(ofAttribute: "reference"),
            userList: node["userList"]["name"].value(),
            broadcastMessage: node["broadcastMessage"].value(),
            noteMessage: node["formulaList"]["formula"]["value"].value(),
            pointedObject: node["pointedObject"].value(ofAttribute: "name"),
            spinnerSelectionID: node["spinnerSelectionID"].value()
        )
    }
}
