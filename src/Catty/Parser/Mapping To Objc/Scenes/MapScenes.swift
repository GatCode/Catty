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

    static func mapScenesToObjectList(input: [CBProjectScene]?, project: Project) -> NSMutableArray {
        var objectList = [SpriteObject]()

        // since in 0.991 there are no multiple scenes
        guard let input = input?.first?.objectList?.object else { return  NSMutableArray(array: objectList) }

        for object in input {
            objectList.append(mapCBObjectToSpriteObject(input: object, objects: input, project: project))
        }

        return NSMutableArray(array: objectList)
    }

    static func mapCBObjectToSpriteObject(input: CBObject, objects: [CBObject], project: Project) -> SpriteObject {
        let item = SpriteObject()
        item.name = (input.name)?.replacingOccurrences(of: "Hintergrund", with: "Background")
        item.project = project
        item.lookList = mapLookListToObject(input: input.lookList)
        item.soundList = mapSoundListToObject(input: input.soundList)
        item.scriptList = mapScriptListToObject(input: input.scriptList, object: item, lookList: item.lookList, soundList: item.soundList, objects: objects, project: project)
        // TODO: map variables

        return item
    }
}
