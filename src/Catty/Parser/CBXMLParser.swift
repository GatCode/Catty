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

class CBXMLParser2: NSObject {

    private var xmlPath: String = ""
    private var project: CBProject?

    init?(path: String) {
        if path.isEmpty {
            return nil
        }
        xmlPath = path
    }

    func parseProject(completion: (Bool) -> Void) {

        var xmlFile = String()
        do {
            xmlFile = try String(contentsOfFile: self.xmlPath, encoding: .utf8)
        } catch {
            // TODO: ERROR HANDLING
        }

        let xml = SWXMLHash.parse(xmlFile)

        do {
            project = try xml["program"].value()
            completion(true)
        } catch {
            // TODO: ERROR HANDLING
        }
    }

    func getProject() -> CBProject? {
        return project
    }
}