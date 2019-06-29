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

    static func mapScrToObj(input: CBScriptList?, object: SpriteObject, objs: [CBObject], cbo: CBObject, proj: Project, cbp: CBProject?, completion: (NSMutableArray?, CBXMLError?) -> Void) {

        var scriptList = [Script]()
        guard let input = input?.script else { completion(nil, .scriptListMapError); return }

        for script in input {
            var obj = Script()

            if script.type?.uppercased() == kStartScript.uppercased() {
                obj = StartScript()
            } else if script.type == kWhenScript {
                let whenScript = WhenScript()
                if let action = script.action {
                    whenScript.action = action
                } else {
                    completion(nil, .scriptListMapError)
                }
                obj = whenScript
            } else if script.type?.uppercased() == kWhenTouchDownScript.uppercased() {
                obj = WhenTouchDownScript()
            } else if script.type?.uppercased() == kBroadcastScript.uppercased() {
                let broadcastScript = BroadcastScript()
                if let msg = script.receivedMessage {
                    broadcastScript.receivedMessage = msg
                } else {
                    completion(nil, .scriptListMapError)
                }
                obj = broadcastScript
            } else if script.type?.hasSuffix(kScript) ?? false {
                let broadcastScript = BroadcastScript()
                if let type = script.type {
                    let msg = String(format: "%@ %@", "timeNow in hex: ", kLocalizedUnsupportedScript, type)
                    broadcastScript.receivedMessage = msg
                } else {
                    completion(nil, .scriptListMapError)
                }
                obj = broadcastScript
                // TODO handle with black box logic
            } else {
                completion(nil, .unsupportedScript)
            }

            obj.object = object
            var mappingError: CBXMLError?
            mapBrToScr(inp: script, scr: obj, obj: object, cbo: cbo, objs: objs, proj: proj, cbp: cbp) { result, error in
                if error != nil {
                    mappingError = error
                }
                obj.brickList = result
            }
            if mappingError != nil {
                completion(nil, mappingError)
                break
            }

            scriptList.append(obj)
        }

        completion(NSMutableArray(array: scriptList), nil)
    }
}
