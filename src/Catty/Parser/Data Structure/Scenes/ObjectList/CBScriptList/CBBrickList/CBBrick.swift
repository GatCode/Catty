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
    let soundReference: String?
    let sound: CBSound?
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
    let xPosition: CBFormula?
    let yPosition: CBFormula?

    static func deserialize(_ node: XMLIndexer) throws -> CBBrick {

        var tmpType: String?
        tmpType = try? node.value(ofAttribute: "type")

        if tmpType == nil {
            var splittedAndCleaned = [String]()

            let splittedDescription = node.description.split(separator: ">")
            splittedDescription.forEach { element in
                splittedAndCleaned.append(element.replacingOccurrences(of: "<", with: ""))
            }
            if splittedAndCleaned.first?.isEmpty == false {
                tmpType = splittedAndCleaned.first
            }
        }

        var userVar: String?
        userVar = try? node["userVariable"]["name"].value()
        if userVar?.isEmpty ?? true {
            userVar = try? node["userVariable"].value()
        }
        if userVar?.isEmpty ?? true {
            userVar = try? node["userVariableName"].value()
        }

        var tmpFormulaTree: CBFormulaList?
        tmpFormulaTree = try? node["size"]["formulaTree"].value()

        if tmpFormulaTree == nil {
            tmpFormulaTree = try? node["variableFormula"]["formulaTree"].value()
        }

        var tmpNoteMessage: String?
        tmpNoteMessage = try? node["formulaList"]["formula"]["value"].value()
        if tmpNoteMessage == nil {
            tmpNoteMessage = try? node["text"].value()
        }

        return try CBBrick(
            name: node["name"].value(),
            type: tmpType,
            soundReference: node["sound"].value(ofAttribute: "reference"),
            sound: node["sound"].value(),
            commentedOut: node["commentedOut"].value(),
            formulaList: node["formulaList"].value(),
            formulaTree: tmpFormulaTree,
            lookReference: node["look"].value(ofAttribute: "reference"),
            userVariable: userVar,
            userVariableReference: node["userVariable"].value(ofAttribute: "reference"),
            userList: node["userList"]["name"].value(),
            broadcastMessage: node["broadcastMessage"].value(),
            noteMessage: tmpNoteMessage,
            pointedObject: node["pointedObject"].value(ofAttribute: "name"),
            spinnerSelectionID: node["spinnerSelectionID"].value(),
            xPosition: node["xPosition"]["formulaTree"].value(),
            yPosition: node["yPosition"]["formulaTree"].value()
        )
    }
}
