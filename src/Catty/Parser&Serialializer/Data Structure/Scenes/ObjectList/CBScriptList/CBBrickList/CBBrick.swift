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
    var type: String?
    var soundReference: String?
    var sound: CBSound?
    var commentedOut: String?
    var formulaList: CBFormulaList?
    var formulaTree: CBFormulaList?
    var xDestination: CBFormulaList?
    var yDestination: CBFormulaList?
    var lookReference: String?
    var userVariable: String?
    var userVariableReference: String?
    var userList: String?
    var broadcastMessage: String?
    var noteMessage: String?
    var pointedObject: CBObject?
    var pointedObjectReference: String?
    var spinnerSelectionID: String?
    var xPosition: CBFormula?
    var yPosition: CBFormula?
    var ifReference: String?

    init(type: String? = nil,
         soundReference: String? = nil,
         sound: CBSound? = nil,
         commentedOut: String? = nil,
         formulaList: CBFormulaList? = nil,
         formulaTree: CBFormulaList? = nil,
         xDestination: CBFormulaList? = nil,
         yDestination: CBFormulaList? = nil,
         lookReference: String? = nil,
         userVariable: String? = nil,
         userVariableReference: String? = nil,
         userList: String? = nil,
         broadcastMessage: String? = nil,
         noteMessage: String? = nil,
         pointedObject: CBObject? = nil,
         pointedObjectReference: String? = nil,
         spinnerSelectionID: String? = nil,
         xPosition: CBFormula? = nil,
         yPosition: CBFormula? = nil,
         ifReference: String? = nil) {
        self.type = type
        self.soundReference = soundReference
        self.sound = sound
        self.commentedOut = commentedOut
        self.formulaList = formulaList
        self.formulaTree = formulaTree
        self.xDestination = xDestination
        self.yDestination = yDestination
        self.lookReference = lookReference
        self.userVariable = userVariable
        self.userVariableReference = userVariableReference
        self.userList = userList
        self.broadcastMessage = broadcastMessage
        self.noteMessage = noteMessage
        self.pointedObject = pointedObject
        self.pointedObjectReference = pointedObjectReference
        self.spinnerSelectionID = spinnerSelectionID
        self.xPosition = xPosition
        self.yPosition = yPosition
        self.ifReference = ifReference
    }

    static func deserialize(_ node: XMLIndexer) throws -> CBBrick {
        var tmpIfReference: String?
        var tmpType: String?
        tmpType = try? node.value(ofAttribute: "type")

        let tmpBrickName: String?
        tmpBrickName = try? node["name"].value()
        if tmpType == nil && tmpBrickName != "brick" {
            tmpType = tmpBrickName
        }

        var tmpUserVariableReference: String?
        tmpUserVariableReference = try? node["userVariable"].value(ofAttribute: "reference")
        if tmpUserVariableReference == nil {
            tmpUserVariableReference = try? node["userList"].value(ofAttribute: "reference")
        }

        if tmpType == nil {
            var splittedAndCleaned = [String]()

            let splittedDescription = node.description.split(separator: ">")
            splittedDescription.forEach { element in
                splittedAndCleaned.append(element.replacingOccurrences(of: "<", with: ""))
            }
            if let slittedAndCleanedString = splittedAndCleaned.first {
                let splittedType = slittedAndCleanedString.split(separator: " ")
                if splittedType.count >= 2, let type = splittedType.first, let reference = splittedType.last {
                    tmpType = String(type)
                    tmpIfReference = String(reference)
                } else {
                    tmpType = splittedAndCleaned.first
                }
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

        var userList: String?
        userList = try? node["userList"]["name"].value()
        if userList?.isEmpty ?? true {
            userList = try? node["userList"].value()
        }
        if userList?.isEmpty ?? true {
            userList = try? node["userListName"].value()
        }

        var tmpFormulaTree: CBFormulaList?
        let formulaCombinations = [
            ("size", "formulaTree"),
            ("variableFormula", "formulaTree"),
            ("timeToWaitInSeconds", "formulaTree"),
            ("ifCondition", "formulaTree"),
            ("xMovement", "formulaTree"),
            ("yMovement", "formulaTree"),
            ("xPosition", "formulaTree"),
            ("yPosition", "formulaTree"),
            ("durationInSeconds", "formulaTree"),
            ("timesToRepeat", "formulaTree"),
            ("degrees", "formulaTree"),
            ("steps", "formulaTree"),
            ("transparency", "formulaTree"),
            ("volume", "formulaTree"),
            ("changeGhostEffect", "formulaTree")
        ]
        for combination in formulaCombinations {
            tmpFormulaTree = try? node[combination.0][combination.1].value()
            if tmpFormulaTree != nil {
                break
            }
        }

        var tmpNoteMessage: String?
        tmpNoteMessage = try? node["formulaList"]["formula"]["value"].value()
        if tmpNoteMessage == nil {
            tmpNoteMessage = try? node["text"].value()
        }
        if tmpNoteMessage == nil {
            tmpNoteMessage = try? node["note"].value()
        }

        return try CBBrick(
            type: tmpType,
            soundReference: node["sound"].value(ofAttribute: "reference"),
            sound: node["sound"].value(),
            commentedOut: node["commentedOut"].value(),
            formulaList: node["formulaList"].value(),
            formulaTree: tmpFormulaTree,
            xDestination: node["xDestination"]["formulaTree"].value(),
            yDestination: node["yDestination"]["formulaTree"].value(),
            lookReference: node["look"].value(ofAttribute: "reference"),
            userVariable: userVar,
            userVariableReference: tmpUserVariableReference,
            userList: userList,
            broadcastMessage: node["broadcastMessage"].value(),
            noteMessage: tmpNoteMessage,
            pointedObject: node["pointedObject"].value(),
            pointedObjectReference: node["pointedObject"].value(ofAttribute: "name"),
            spinnerSelectionID: node["spinnerSelectionID"].value(),
            xPosition: node["xPosition"]["formulaTree"].value(),
            yPosition: node["yPosition"]["formulaTree"].value(),
            ifReference: tmpIfReference
        )
    }
}
