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

struct CBLRChild: XMLIndexerDeserializable {
    var type: String?
    var value: String?
    var leftChild: [CBLRChild?] //wrapped in array to allow recusive calling
    var rightChild: [CBLRChild?]

    init(type: String? = nil,
         value: String? = nil,
         leftChild: [CBLRChild?] = [],
         rightChild: [CBLRChild?] = []) {
        self.type = type
        self.value = value
        self.leftChild = leftChild
        self.rightChild = rightChild
    }

    static func deserialize(_ node: XMLIndexer) throws -> CBLRChild {

        var left = [CBLRChild?]()
        var right = [CBLRChild?]()

        var resultLeft: CBLRChild?
        var resultRight: CBLRChild?

        resultLeft = try node["leftChild"].value()
        resultRight = try node["rightChild"].value()

        left.append(resultLeft)
        right.append(resultRight)

        return try CBLRChild(
            type: node["type"].value(),
            value: node["value"].value(),
            leftChild: left,
            rightChild: right
        )
    }
}
