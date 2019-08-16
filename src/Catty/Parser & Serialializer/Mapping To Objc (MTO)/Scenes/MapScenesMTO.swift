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

extension CBXMLMappingToObjc {

    static func mapScenes(project: CBProject?, currentProject: inout Project) -> NSMutableArray? {
        guard let project = project else { return nil }
        guard let scenes = project.scenes else { return nil }
        var mappedScenes = [Scene]()

        for scene in scenes {
            var mappedScene = Scene(project: currentProject)
            mappedScene.name = scene.name ?? "Scene 1" // TODO: Implement localized string!!!
            if let mappedObjectList = mapObjectList(scene: scene, project: project, currentProject: &currentProject, currentScene: mappedScene) as? [SpriteObject] {
                mappedScene.setObjectList(objectList: mappedObjectList)
            }
            if let mappedData = mapDataMTO(project: project, currentProject: &currentProject, scene: scene, currentScene: &mappedScene) {
                mappedScene.data = mappedData
            }
            mappedScene.originalWidth = scene.originalWidth
            mappedScene.originalHeight = scene.originalHeight
            mappedScenes.append(mappedScene)
        }

        return NSMutableArray(array: mappedScenes)
    }

    static func mapDataMTO(project: CBProject?, currentProject: inout Project, scene: CBProjectScene, currentScene: inout Scene) -> SceneData? {
        let data = SceneData()
        data.objectListOfLists = mapObjectListOfListsToDataMTO(project: project, currentProject: &currentProject, scene: scene, currentScene: &currentScene)
        data.objectVariableList = mapObjectVariableListToDataMTO(project: project, currentProject: &currentProject, scene: scene, currentScene: &currentScene)
        return data
    }

    static func mapObjectListOfListsToDataMTO(project: CBProject?, currentProject: inout Project, scene: CBProjectScene, currentScene: inout Scene) -> OrderedMapTable? {
        let result = OrderedMapTable.weakToStrongObjectsMapTable() as! OrderedMapTable

        if let objectListOfList = scene.data?.objectListOfList?.entry {
            for entry in objectListOfList {
                if let lists = entry.list {

                    let referencedObject = resolveObjectReference(reference: entry.object, project: project, scene: &currentScene)?.pointee

                    var referencedList = [UserVariable]()
                    for list in lists {
                        if list.reference != nil {
                            if let element = resolveUserVariableReference(reference: list.reference, project: project, scene: &currentScene) {
                                referencedList.append(element.pointee)
                            }
                        } else if let value = list.value {
                            referencedList.append(allocLocalUserVariable(name: value, isList: true))
                        }
                    }

                    result.setObject(NSArray(array: referencedList), forKey: referencedObject)
                }
            }
        }

        return result
    }

    static func mapObjectVariableListToDataMTO(project: CBProject?, currentProject: inout Project, scene: CBProjectScene, currentScene: inout Scene) -> OrderedMapTable? {
        let result = OrderedMapTable.weakToStrongObjectsMapTable() as! OrderedMapTable

        if let objectVariableList = scene.data?.objectVariableList?.entry {
            for entry in objectVariableList {
                if let lists = entry.list {

                    let referencedObject = resolveObjectReference(reference: entry.object, project: project, scene: &currentScene)?.pointee

                    var referencedList = [UserVariable]()
                    for list in lists {
                        if list.reference != nil {
                            if let element = resolveUserVariableReference(reference: list.reference, project: project, scene: &currentScene) {
                                referencedList.append(element.pointee)
                            }
                        } else if let value = list.value {
                            referencedList.append(allocLocalUserVariable(name: value, isList: false))
                        }
                    }

                    result.setObject(NSArray(array: referencedList), forKey: referencedObject)
                }
            }
        }

        return result
    }
}
