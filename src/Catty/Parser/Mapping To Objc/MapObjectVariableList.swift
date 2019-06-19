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

    static func getObjectVariableMapFrom(project: CBProject?) -> OrderedDictionary<String, Any> {
        var objectVariableMap = OrderedDictionary<String, Any>()
        var mapIndex = 0

        if let objectVarList = project?.scenes?.first?.data?.objectVariableList?.entry {
            for variable in objectVarList {

                var foundKey = ""
                var foundObject = NSArray()
                guard let objects = project?.scenes?.first?.objectList?.object else { break }

                if let range = variable.object?.range(of: "[(0-9)*]", options: .regularExpression) {
                    let index = String(variable.object?[range] ?? "")
                    if let idx = Int(index), idx <= objects.count {
                        let object = objects[idx - 1]
                        if let name = object.name {
                            foundKey = name
                            var arr = [UserVariable]()

                            if let scriptList = object.scriptList?.script {
                                for script in scriptList {
                                    if let brickList = script.brickList?.brick {
                                        for brick in brickList {
                                            if let uVar = brick.userVariable, !uVar.isEmpty {
                                                let mappedUVar = mapUserVariableOrUserList(input: brick)
                                                var alreadyInArray = false
                                                for obj in arr where obj.name == mappedUVar.name {
                                                    alreadyInArray = true
                                                }
                                                if alreadyInArray == false {
                                                    arr.append(mappedUVar)
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            foundObject = NSArray(array: arr)
                        }
                    }
                } else if objects.count >= 1 {
                    if let object = objects.first, let name = object.name {
                        foundKey = name

                        var arr = [UserVariable]()

                        if let scriptList = object.scriptList?.script {
                            for script in scriptList {
                                if let brickList = script.brickList?.brick {
                                    for brick in brickList {
                                        if let uVar = brick.userVariable, !uVar.isEmpty {
                                            let mappedUVar = mapUserVariableOrUserList(input: brick)
                                            var alreadyInArray = false
                                            for obj in arr where obj.name == mappedUVar.name {
                                                alreadyInArray = true
                                            }
                                            if alreadyInArray == false {
                                                arr.append(mappedUVar)
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        foundObject = NSArray(array: arr)
                    }
                }
                _ = objectVariableMap.insertElementWithKey(foundKey, value: foundObject, atIndex: mapIndex)
                mapIndex += 1
            }
        }
        return objectVariableMap
    }

    static func getObjectVariableListFrom(map: OrderedDictionary<String, Any>, cbProject: CBProject?, project: Project) -> OrderedMapTable {
        let objectVariableList = OrderedMapTable.weakToStrongObjectsMapTable() as! OrderedMapTable
        for obj in map {

            var spriteObject = SpriteObject()

            if let objectList = cbProject?.scenes?.first?.objectList?.object {
                for object in objectList {
                    let mappedObject = mapCBObjectToSpriteObject(input: object, objects: objectList, project: project)
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
