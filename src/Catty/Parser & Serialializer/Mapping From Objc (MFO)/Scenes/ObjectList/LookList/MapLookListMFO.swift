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

    static func mapLookList(project: Project, object: SpriteObject?) -> CBLookList? {
        guard let object = object else { return nil }
        guard let lookList = object.lookList else { return nil }
        var mappedLooks = [CBLook]()

        for look in lookList {
            if let look = look as? Look {
                mappedLooks.append(CBLook(name: look.name, fileName: look.fileName))
            }
        }

        return CBLookList(looks: mappedLooks)
    }

    static func resolveLookPath(look: Look?, currentObject: CBObject) -> String? {
        guard let lookList = currentObject.lookList?.looks else { return nil }

        for (idx, refLook) in lookList.enumerated() where refLook.name == look?.name {
            return "../../../../../lookList/" + (idx == 0 ? "look" : "look[\(idx + 1)]")
        }

        return nil
    }
}
