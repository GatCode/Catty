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

import SWXMLHash

struct CBUserVariable: XMLIndexerDeserializable {
    let value: String?
    let reference: String?

    static func deserialize(_ node: XMLIndexer) throws -> CBUserVariable {
        var tmpValue: String?
        var tmpReference: String?
        tmpValue = try? node["userVariable"].value()
        tmpReference = try? node["userVariable"].value(ofAttribute: "reference")

        if tmpValue == nil {
            tmpValue = try? node["userList"].value()
        }

        if tmpReference == nil {
            tmpReference = try? node["userList"].value(ofAttribute: "reference")
        }

        if tmpValue == nil {
            tmpValue = try? node.value()
        }

        if tmpReference == nil {
            tmpReference = try? node.value(ofAttribute: "reference")
        }

        return CBUserVariable(
            value: tmpValue?.isEmpty == true ? nil : tmpValue,
            reference: tmpReference?.isEmpty == true  ? nil : tmpReference
        )
    }
}
