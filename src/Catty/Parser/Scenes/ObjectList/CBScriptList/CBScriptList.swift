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

import SWXMLHash

struct CBScriptList: XMLIndexerDeserializable {
    let script: [CBScript]?

    static func deserialize(_ node: XMLIndexer) throws -> CBScriptList {

        var result = [CBScript]()

        for child in node.children {

            let subXML = child.description
            var childXML = [String]()

            let splitted = subXML.split(separator: ">")
            splitted.forEach { val in
                childXML.append(val + ">")
            }

            var childName: String?
            childName = child.value(ofAttribute: "type")

            if let unfilteredChildName = childXML.first, childName == nil {
                let charSet = CharacterSet.letters
                childName = String(unfilteredChildName.unicodeScalars.filter { charSet.contains($0) })
            }

            childXML.removeFirst()
            childXML.insert("<resolver name=\"\(childName ?? "")\">", at: 0)
            childXML.removeLast()
            childXML.insert("</resolver>", at: childXML.count)

            if childXML.joined() != "" {
                let xml = SWXMLHash.parse(childXML.joined())

                let newScript: CBScript?
                newScript = try xml["resolver"].value()

                if let newScript = newScript {
                    result.append(newScript)
                }
            }
        }

        return CBScriptList(
            script: result
        )
    }
}
