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

extension CBXMLMappingFromObjc {

    // MARK: - Map ObjectVariableList
    static func mapObjectVariableList(project: Project) -> CBObjectVariableList {

        var mappedEntries = [CBObjectVariableEntry]()

        for index in 0..<project.variables.objectVariableList.count() {
            mappedEntries.append(mapObjectVariableListEntry(project: project, referencedIndex: index))
        }

        return CBObjectVariableList(entry: mappedEntries)
    }

    // MARK: - Map ObjectListOfLists
    static func mapObjectListOfLists(project: Project) -> CBObjectListofList {

        var mappedEntries = [CBObjectListOfListEntry]()

        for index in 0..<project.variables.objectListOfLists.count() {
            mappedEntries.append(mapObjectListOfListsEntry(project: project, referencedIndex: index))
        }

        return CBObjectListofList(entry: mappedEntries)
    }

    static func mapObjectVariableListEntry(project: Project, referencedIndex: UInt) -> CBObjectVariableEntry {
        let referencedObject = project.variables.objectVariableList.key(at: referencedIndex)
        let referencedVariableList = project.variables.objectVariableList.object(at: referencedIndex)
        let spriteObject = referencedObject as? SpriteObject
        let userVariableList = referencedVariableList as? [UserVariable]

        let object = resolveObjectPath(project: project, object: spriteObject)
        let list = mapObjectVariableListEntryList(project: project, list: userVariableList, object: spriteObject, objectPath: object, isList: false)

        return CBObjectVariableEntry(object: object, list: list)
    }

    static func mapObjectListOfListsEntry(project: Project, referencedIndex: UInt) -> CBObjectListOfListEntry {
        let referencedObject = project.variables.objectListOfLists.key(at: referencedIndex)
        let referencedVariableList = project.variables.objectListOfLists.object(at: referencedIndex)
        let spriteObject = referencedObject as? SpriteObject
        let userVariableList = referencedVariableList as? [UserVariable]

        let object = resolveObjectPath(project: project, object: spriteObject)
        let list = mapObjectVariableListEntryList(project: project, list: userVariableList, object: spriteObject, objectPath: object, isList: true)

        return CBObjectListOfListEntry(object: object, list: list)
    }

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
        // TODO: this just works for 0.991
        for userVariable in list {
            if CBXMLMappingFromObjc.globalVariableList.contains(where: { $0.0 == userVariable.name && $0.1 == isList }) == false {
                if let referencedDictionary = CBXMLMappingFromObjc.localVariableList.first(where: { $0.0 == object }) {
                    if let referencedArray = referencedDictionary.1.first(where: { $0[userVariable] != nil }) {
                        if let referencedUserVariablePosition = referencedArray.first(where: { $0.key == userVariable }) {
                            let scrString = referencedUserVariablePosition.1.1 == 0 ? "script/" : "script[\(referencedUserVariablePosition.1.1 + 1)]/"
                            let brString = referencedUserVariablePosition.1.2 == 0 ? "brick/" : "brick[\(referencedUserVariablePosition.1.2 + 1)]/"
                            let referenceString = "../" + objectPath + "/scriptList/" + scrString + "brickList/" + brString + (isList ? "userList" : "userVariable")
                            mappedUserVariables.append(CBUserVariable(value: "userVariable", reference: referenceString))
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
                    mappedUserVariables.append(CBUserVariable(value: "userVariable", reference: referenceString))
                }
            }
        }

        return mappedUserVariables
    }

    // MARK: - Map ProgramVariableList
    static func mapProgramVariableList(project: Project) -> CBProgramVariableList {
        var mappedProgramVariables = [CBUserProgramVariable]()

        for variable in globalVariableList where variable.1 == false {
            for v in CBXMLMappingFromObjc.userVariableList where v.0?.name == variable.0 {
                let referencedPosition = v.1
                let objString = referencedPosition.0 == 0 ? "object/" : "object[\(referencedPosition.0 + 1)]/"
                let scrString = referencedPosition.1 == 0 ? "script/" : "script[\(referencedPosition.1 + 1)]/"
                let brString = referencedPosition.2 == 0 ? "brick/" : "brick[\(referencedPosition.2 + 1)]/"
                var referenceString = ""
                if CBXMLSerializer.serializeInCBL991 {
                    referenceString = "../../../objectList/" + objString + "scriptList/" + scrString + "brickList/" + brString + "userVariable"
                } else {
                    referenceString = "../../scenes/scene/objectList/" + objString + "scriptList/" + scrString + "brickList/" + brString + "userVariable"
                }
                mappedProgramVariables.append(CBUserProgramVariable(reference: referenceString))
            }
        }

        return CBProgramVariableList(userVariable: mappedProgramVariables)
    }

    // MARK: - Map ProgramListOfLists
    static func mapProgramListOfLists(project: Project) -> CBProgramListOfLists {
        var mappedProgramVariables = [CBProgramList]()

        for variable in globalVariableList where variable.1 == true {
            for v in CBXMLMappingFromObjc.userVariableList where v.0?.name == variable.0 {
                let referencedPosition = v.1
                let objString = referencedPosition.0 == 0 ? "object/" : "object[\(referencedPosition.0 + 1)]/"
                let scrString = referencedPosition.1 == 0 ? "script/" : "script[\(referencedPosition.1 + 1)]/"
                let brString = referencedPosition.2 == 0 ? "brick/" : "brick[\(referencedPosition.2 + 1)]/"
                var referenceString = ""
                if CBXMLSerializer.serializeInCBL991 {
                    referenceString = "../../../objectList/" + objString + "scriptList/" + scrString + "brickList/" + brString + "userList"
                } else {
                    referenceString = "../../scenes/scene/objectList/" + objString + "scriptList/" + scrString + "brickList/" + brString + "userList"
                }
                mappedProgramVariables.append(CBProgramList(reference: referenceString))
            }
        }

        return CBProgramListOfLists(list: mappedProgramVariables)
    }
}
