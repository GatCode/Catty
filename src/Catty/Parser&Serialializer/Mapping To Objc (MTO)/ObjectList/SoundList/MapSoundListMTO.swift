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

    static func mapSoundList(soundList: CBSoundList?, project: CBProject?, object: CBObject?) -> NSMutableArray? {
        guard let input = soundList?.sounds else { return nil }
        guard let project = project else { return nil }

        var soundList = [Sound]()
        for sound in input {

            if let resolvedSound = resolveSoundReference(reference: sound.reference, project: project, object: object), soundList.contains(resolvedSound) == false {
                soundList.append(resolvedSound)
            }

            if let newSound = allocSound(name: sound.name, filename: sound.fileName), soundList.contains(newSound) == false {
                soundList.append(newSound)
            }
        }

        return NSMutableArray(array: soundList)
    }

    static func resolveSoundReference(reference: String?, project: CBProject?, object: CBObject?) -> Sound? {
        let resolvedReferenceString = resolveReferenceStringShort(reference: reference, project: project, object: object)
        guard let resolvedString = resolvedReferenceString else { return nil }

        var soundNameToResolve: String?
        var soundFileNameToResolve: String?
        let sIdx = resolvedString.0 ?? 0
        let bIdx = resolvedString.1 ?? 0

        if let scriptList = object?.scriptList?.scripts, sIdx < scriptList.count {
            if let brickList = scriptList[sIdx].brickList?.bricks, bIdx < brickList.count {
                soundNameToResolve = brickList[bIdx].sound?.name
                soundFileNameToResolve = brickList[bIdx].sound?.fileName
            }
        }

        return allocSound(name: soundNameToResolve, filename: soundFileNameToResolve)
    }

    static func allocSound(name: String?, filename: String?) -> Sound? {
        guard let name = name else { return nil }
        guard let filename = filename else { return nil }

        let newSound = Sound(name: name, fileName: filename)

        for sound in mappingSoundList where sound.fileName == newSound.fileName {
            return sound
        }

        mappingSoundList.append(newSound)
        return newSound
    }
}
