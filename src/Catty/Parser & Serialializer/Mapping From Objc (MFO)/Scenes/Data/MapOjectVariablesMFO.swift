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
    static func mapObjectVariableList(scene: Scene, project: Project) -> CBObjectVariableList {

        var mappedEntries = [CBObjectVariableEntry]()

        for index in 0..<UInt(scene.data?.objectVariableList?.count() ?? 0) {
            mappedEntries.append(mapObjectVariableListEntry(scene: scene, project: project, referencedIndex: index))
        }

        return CBObjectVariableList(entry: mappedEntries)
    }

    static func mapObjectVariableListEntry(scene: Scene, project: Project, referencedIndex: UInt) -> CBObjectVariableEntry {
        let referencedObject = scene.data?.objectVariableList?.key(at: referencedIndex)
        let referencedVariableList = scene.data?.objectVariableList?.object(at: referencedIndex)
        let spriteObject = referencedObject as? SpriteObject
        let userVariableList = referencedVariableList as? [UserVariable]

        let object = resolveObjectPath(project: project, object: spriteObject)
        let list = mapObjectVariableListEntryList(project: project, list: userVariableList, object: spriteObject, objectPath: object, isList: false)

        return CBObjectVariableEntry(object: object, list: list)
    }

    // MARK: - Map ObjectListOfLists
    static func mapObjectListOfLists(scene: Scene, project: Project) -> CBObjectListofList {

        var mappedEntries = [CBObjectListOfListEntry]()

        for index in 0..<UInt(scene.data?.objectListOfLists?.count() ?? 0) {
            mappedEntries.append(mapObjectListOfListsEntry(scene: scene, project: project, referencedIndex: index))
        }

        return CBObjectListofList(entry: mappedEntries)
    }

    static func mapObjectListOfListsEntry(scene: Scene, project: Project, referencedIndex: UInt) -> CBObjectListOfListEntry {
        let referencedObject = scene.data?.objectListOfLists?.key(at: referencedIndex)
        let referencedVariableList = scene.data?.objectListOfLists?.object(at: referencedIndex)
        let spriteObject = referencedObject as? SpriteObject
        let userVariableList = referencedVariableList as? [UserVariable]

        let object = resolveObjectPath(project: project, object: spriteObject)
        let list = mapObjectVariableListEntryList(project: project, list: userVariableList, object: spriteObject, objectPath: object, isList: true)

        return CBObjectListOfListEntry(object: object, list: list)
    }
}
