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

    static func mapScenesToCBProject(project: Project) -> [CBProjectScene] {
        var mappedScene = CBProjectScene()

        mappedScene.name = "Szene 1"
        mappedScene.objectList = mapObjectList(project: project)
        mappedScene.data = mapData(project: project)
        mappedScene.originalHeight = project.header.screenHeight.stringValue
        mappedScene.originalWidth = project.header.screenWidth.stringValue

        return [mappedScene]
    }

    static func mapObjectList(project: Project) -> CBObjectList {
        var mappedObjectList = [CBObject]()

        for object in project.objectList {
            var mappedObject = CBObject()
            mappedObject.name = (object as? SpriteObject)?.name

            mappedObject.lookList = mapLookList(project: project, object: object as? SpriteObject)
            mappedObject.soundList = mapSoundList(project: project, object: object as? SpriteObject)
            mappedObject.scriptList = mapScriptList(project: project, object: object as? SpriteObject, currentObject: mappedObject)
            mappedObject.userBrickList = CBUserBrickList(userBricks: nil)
            mappedObject.nfcTagList = CBNfcTagList(nfcTags: nil)

            mappedObjectList.append(mappedObject)
            CBXMLMappingFromObjc.objectList.append((object as? SpriteObject, CBXMLMappingFromObjc.currentSerializationPosition))
            CBXMLMappingFromObjc.currentSerializationPosition.0 += 1
            CBXMLMappingFromObjc.currentSerializationPosition.1 = 0
        }

        return CBObjectList(objects: mappedObjectList)
    }
}
