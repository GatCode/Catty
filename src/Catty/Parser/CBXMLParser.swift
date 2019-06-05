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

import AEXML
import SWXMLHash

@objc class CBXMLParser2: NSObject {

    private var xmlPath: String = ""
    private var project: CBProject?

    @objc init?(path: String) {
        if path.isEmpty {
            return nil
        }
        xmlPath = path
    }

    func parseProject(completion: @escaping (CBXMLParserError?) -> Void) {
        guard let xmlFile = try? String(contentsOfFile: self.xmlPath, encoding: .utf8) else { completion(.invalidPath); return }

        let xml = SWXMLHash.parse(xmlFile)

        do {
            project = try xml["program"].value()
            completion(nil)
        } catch {
            completion(.parsingError)
        }
    }

    func getProject() -> CBProject? {
        return project
    }

    // for legacy code support
    @objc func parseProject() -> Bool {
        var retVal = false

        parseProject { error in
            retVal = error != nil ? false : true
        }

        return retVal
    }

    // for legacy code support
    @objc func getProjectObjc() -> Project? {

        let mappedProject = Project()
        mappedProject.header = CBXMLMapping.mapHeader(input: project?.header)

        return mappedProject
    }
}

enum CBXMLParserError: Error {
    case invalidPath
    case parsingError
}
