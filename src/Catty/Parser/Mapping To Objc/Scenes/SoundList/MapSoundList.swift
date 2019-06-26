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

    static func mapSoundListToObject(input: CBSoundList?, cbProject: CBProject?, object: CBObject) -> NSMutableArray {
        var soundList = [Sound]()
        guard let input = input?.sound else { return  NSMutableArray(array: soundList) }

        for sound in input {
            if let ref = sound.reference {
                var brick: CBBrick? = nil
                if ref.split(separator: "/").count < 9 {
                    let extr = extractAbstractNumbersFrom(object: object, reference: ref, project: cbProject)
                    if let sl = object.scriptList?.script, sl.count > extr.0, let bl = sl[extr.0].brickList?.brick, bl.count > extr.1 {
                        brick = bl[extr.1]
                    }
                } else {
                    let extr = extractAbstractNumbersFrom(reference: ref, project: cbProject)
                    if let ol = cbProject?.scenes?.first?.objectList?.object, ol.count > extr.0 {
                        if let sl = ol[extr.0].scriptList?.script, sl.count > extr.1, let bl = sl[extr.1].brickList?.brick, bl.count > extr.2 {
                            brick = bl[extr.2]
                        }
                    }
                }
                if let brick = brick, let name = brick.sound?.name, let filename = brick.sound?.fileName {
                    let soundToAppend = Sound(name: name, fileName: filename)
                    if soundList.contains(soundToAppend) == false {
                        soundList.append(soundToAppend)
                    }
                }
            } else if let name = sound.name, let filename = sound.fileName {
                let soundToAppend = Sound(name: name, fileName: filename)
                if soundList.contains(soundToAppend) == false {
                    soundList.append(soundToAppend)
                }
            }
        }

        return NSMutableArray(array: soundList)
    }
}
