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

    static func mapSoundList(project: Project, object: SpriteObject?) -> CBSoundList? {
        guard let object = object else { return nil }
        guard let soundList = object.soundList else { return nil }
        var mappedSounds = [CBSound]()

        for sound in soundList {
            if let sound = sound as? Sound {
                mappedSounds.append(CBSound(fileName: sound.fileName, name: sound.name, reference: nil))
            }
        }

        return CBSoundList(sounds: mappedSounds)
    }

    static func resolveSoundPath(sound: Sound?, currentObject: CBObject) -> String? {
        guard let soundList = currentObject.soundList?.sounds else { return nil }

        for (idx, refSound) in soundList.enumerated() where refSound.name == sound?.name {
            return "../../../../../soundList/" + (idx == 0 ? "sound" : "sound[\(idx + 1)]")
        }

        return nil
    }
}
