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

    static func mapScriptList(object: CBObject?, objectList: [CBObject]?, project: CBProject?, currentObject: inout SpriteObject) -> NSMutableArray? {
        guard let scriptList = object?.scriptList?.scripts else { return nil }

        var resultScriptList = [Script]()
        for script in scriptList {
            if let scr = mapScript(script: script, objectList: objectList, object: object, project: project, currentObject: &currentObject) {
                scr.object = currentObject
                resultScriptList.append(scr)
            }
        }

        return NSMutableArray(array: resultScriptList)
    }

    static func mapScript(script: CBScript?, objectList: [CBObject]?, object: CBObject?, project: CBProject?, currentObject: inout SpriteObject) -> Script? {
        guard let script = script else { return nil }

        var result: Script?
        switch script.type?.uppercased() {
        case kStartScript.uppercased():
            result = StartScript()
        case kWhenScript.uppercased():
            let scr = WhenScript()
            if let action = script.action {
                scr.action = action
            }
            result = scr
        case kWhenTouchDownScript.uppercased():
            result = WhenTouchDownScript()
        case kBroadcastScript.uppercased():
            let scr = BroadcastScript()
            if let msg = script.receivedMessage {
                scr.receivedMessage = msg
                scr.receivedMsg = msg
            }
            result = scr
        default:
            if let type = script.type, type.hasSuffix(kScript) == true {
                let scr = BroadcastScript()
                scr.receivedMessage = String(format: "%@ %@", kLocalizedUnsupportedScript, type)
                scr.receivedMsg = scr.receivedMessage
                unsupportedElements.append(type)
                result = scr
            }
        }

        if let res = result {
            res.isUserScript = script.isUserScript
            res.action = script.action
            res.brickList = mapBrickList(script: script, objectList: objectList, object: object, project: project, currScript: &result, currObject: &currentObject)
            return res
        }

        return nil
    }
}
