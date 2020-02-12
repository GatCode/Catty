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

extension CBXMLMappingFromObjc {

    static func resolveObjectPath(project: Project, object: SpriteObject?) -> String? {
        guard let object = object else { return nil }

        if let referencedUserVariable = CBXMLMappingFromObjc.objectList.first(where: { $0.0 == object }) {
            let referencedPosition = referencedUserVariable.1
            return "../../../../objectList/" + (referencedPosition.0 == 0 ? "object" : "object[\(referencedPosition.0 + 1)]")
        }

        return nil
    }

    static func mapObjectVariableListEntryList(project: Project, list: [UserVariable]?, object: SpriteObject?, objectPath: String?, isList: Bool) -> [CBUserVariable]? {
        guard let list = list else { return nil }
        guard let objectPath = objectPath else { return nil }
        var mappedUserVariables = [CBUserVariable]()
        for userVariable in list {
            if CBXMLMappingFromObjc.globalVariableList.contains(where: { $0.0 == userVariable.name && $0.1 == isList }) == false {
                if let referencedDictionary = CBXMLMappingFromObjc.localVariableList.first(where: { $0.0 == object }) {
                    if let referencedArray = referencedDictionary.1.first(where: { $0[userVariable] != nil }) {
                        if let referencedUserVariablePosition = referencedArray.first(where: { $0.key == userVariable }) {
                            let scrString = referencedUserVariablePosition.1.1 == 0 ? "script/" : "script[\(referencedUserVariablePosition.1.1 + 1)]/"
                            let brString = referencedUserVariablePosition.1.2 == 0 ? "brick/" : "brick[\(referencedUserVariablePosition.1.2 + 1)]/"
                            let referenceString = "../" + objectPath + "/scriptList/" + scrString + "brickList/" + brString + (isList ? "userList" : "userVariable")
                            mappedUserVariables.append(CBUserVariable(value: (isList ? "userList" : "userVariable"), reference: referenceString))
                        }
                    }
                }
            } else {
                if let referencedUserVariable = CBXMLMappingFromObjc.userVariableList.first(where: { $0.0 == userVariable }) {
                    let referencedPosition = referencedUserVariable.1
                    let objString = referencedPosition.0 == 0 ? "object/" : "object[\(referencedPosition.0 + 1)]/"
                    let scrString = referencedPosition.1 == 0 ? "script/" : "script[\(referencedPosition.1 + 1)]/"
                    let brString = referencedPosition.2 == 0 ? "brick/" : "brick[\(referencedPosition.2 + 1)]/"
                    let referenceString = "../../../../../objectList/" + objString + "scriptList/" + scrString + "brickList/" + brString + (isList ? "userList" : "userVariable")
                    mappedUserVariables.append(CBUserVariable(value: (isList ? "userList" : "userVariable"), reference: referenceString))
                }
            }
        }

        return mappedUserVariables
    }

    static func resolveProgramVariableOrListOfListsUVarPosition(position: (Int, Int, Int), isList: Bool) -> String {
        let objString = position.0 == 0 ? "object/" : "object[\(position.0 + 1)]/"
        let scrString = position.1 == 0 ? "script/" : "script[\(position.1 + 1)]/"
        let brString = position.2 == 0 ? "brick/" : "brick[\(position.2 + 1)]/"
        var referenceString = ""
        if CBXMLSerializer.serializeInCBL991 {
            referenceString = "../../../objectList/" + objString + "scriptList/" + scrString + "brickList/" + brString + (isList ? "userList" : "userVariable")
        } else {
            referenceString = "../../scenes/scene/objectList/" + objString + "scriptList/" + scrString + "brickList/" + brString + (isList ? "userList" : "userVariable")
        }

        return referenceString
    }
}
