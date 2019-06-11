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

let kStartScript = "StartScript"
let kWhenScript = "WhenScript"
let kWhenTouchDownScript = "WhenTouchDownScript"
let kBroadcastScript = "BroadcastScript"
let kScript = "Script"

extension CBXMLMapping {

    static func mapScriptListToObject(input: CBScriptList?, object: SpriteObject) -> NSMutableArray {
        var scriptList = [Script]()
        guard let input = input?.script else { return  NSMutableArray(array: scriptList) }

        for script in input {
            var obj = Script()

            // TODO: fill other types correctly

            if script.type == kStartScript {
                obj = StartScript()
            } else if script.type == kWhenScript {
                obj = WhenScript()
            } else if script.type == kWhenTouchDownScript {
                obj = WhenTouchDownScript()
            } else if script.type == kBroadcastScript {
                obj = BroadcastScript()
            } else if script.type == kScript {
                obj = Script()
            } else {
                // TODO: unsupported script
            }

            obj.object = object
            obj.brickList = mapBrickListToScript(input: script)

            scriptList.append(obj)
        }

        return NSMutableArray(array: scriptList)
    }
}
