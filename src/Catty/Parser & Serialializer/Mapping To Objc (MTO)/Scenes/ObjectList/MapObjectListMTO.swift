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

    static func mapObjectList(scene: CBProjectScene?, project: CBProject?, currentProject: inout Project, currentScene: Scene?) -> NSMutableArray? {
        guard let project = project else { return nil }
        guard let objectList = scene?.objectList?.objects else { return nil }

        var resultObjectList = [SpriteObject]()
        for object in objectList {
            mappingVariableListLocal.removeAll()

            if let ref = object.reference {
                let resolvedString = resolveReferenceString(reference: ref, project: project)
                if let resolvedString = resolvedString, let oNr = resolvedString.0, oNr < resultObjectList.count {
                    if let sNr = resolvedString.1, sNr < resultObjectList[oNr].scriptList.count, let script = resultObjectList[oNr].scriptList[sNr] as? Script {
                        if let bNr = resolvedString.2, bNr < script.brickList.count, let brick = script.brickList[bNr] as? Brick {
                            if let brick = brick as? PointToBrick, brick.pointedObject != nil {
                                resultObjectList.append(brick.pointedObject)
                            }
                        }
                    }
                }
            } else if let mappedObject = mapObject(object: object, objectList: objectList, project: project, currentScene: currentScene) {
                mappedObject.project = currentProject
                resultObjectList.append(mappedObject)
            }
        }

        return NSMutableArray(array: resultObjectList)
    }

    static func mapObject(object: CBObject?, objectList: [CBObject]?, project: CBProject?, currentScene: Scene?) -> SpriteObject? {
        var result = SpriteObject(scene: currentScene)!
        guard let object = object else { return nil }
        guard let project = project else { return nil }
        guard let lookList = object.lookList else { return nil }
        guard let soundList = object.soundList else { return nil }

        if let alreadyMapped = CBXMLMappingToObjc.spriteObjectList.first(where: { $0.name == object.name }) {
            return alreadyMapped
        }

        result.name = object.name
        result.lookList = mapLookList(lookList: lookList)
        result.soundList = mapSoundList(soundList: soundList, project: project, object: object)
        result.scriptList = mapScriptList(object: object, objectList: objectList, project: project, currentObject: &result)

        CBXMLMappingToObjc.spriteObjectList.append(result)

        return result
    }
}
