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

extension CBXMLMapping {

    static func getObjectListMapFrom(project: CBProject?) -> OrderedDictionary<String, Any> {
        var objectListMap = OrderedDictionary<String, Any>()
        var mapIndex = 0

        if let objectListOfLists = project?.scenes?.first?.data?.objectListOfList?.entry {
            for list in objectListOfLists {

                var foundKey = ""
                var foundObject = NSArray()
                guard let objects = project?.scenes?.first?.objectList?.object else { break }

                if let obj = list.object, objects.count >= 1 {
                    let index = extractAbstractNumbersFrom(reference: obj, project: project).0
                    if index < objects.count {
                        let object = objects[index]
                        if let name = object.name {
                            foundKey = name
                            var arr = [UserVariable]()

                            if let scriptList = object.scriptList?.script {
                                for script in scriptList {
                                    if let brickList = script.brickList?.brick {
                                        for brick in brickList {
                                            if let uList = brick.userList, !uList.isEmpty {
                                                let mappedUList = mapUserVariableOrUserList(input: brick)
                                                var alreadyInArray = false
                                                for obj in arr where obj.name == mappedUList.name {
                                                    alreadyInArray = true
                                                }
                                                if alreadyInArray == false {
                                                    arr.append(mappedUList)
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            foundObject = NSArray(array: arr)
                        }
                    }
                }
                //_ = objectListMap.insertElementWithKey(foundKey, value: foundObject, atIndex: mapIndex)
                objectListMap.forceInsertElementWithKey(foundKey, value: foundObject, atIndex: mapIndex)
                mapIndex += 1
            }
        }
        return objectListMap
    }

    static func getObjectListOfListsFrom(map: OrderedDictionary<String, Any>, cbProject: CBProject?, project: Project) -> OrderedMapTable {
        let objectVariableList = OrderedMapTable.weakToStrongObjectsMapTable() as! OrderedMapTable
        for obj in map {

            var spriteObject = SpriteObject()

            if let objectList = cbProject?.scenes?.first?.objectList?.object {
                for object in objectList {
                    let mappedObject = mapCBObjectToSpriteObject(input: object, objects: objectList, project: project, cbProject: cbProject, blankMap: true)
                    if mappedObject.name == obj.0 {
                        spriteObject = mappedObject
                        break
                    }
                }
            }

            objectVariableList.setObject(obj.1, forKey: spriteObject)
        }
        return objectVariableList
    }
}
