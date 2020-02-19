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

@objcMembers
class XMLParser: NSObject {

    fileprivate var xmlPath: String = ""
    fileprivate var project: CBProject?

    required init(path: String) {
        xmlPath = path
    }

    func parse(completion: @escaping (CBXMLParserError?) -> Void) {
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
}

@objc enum CBXMLParserError: Int {
    private enum CBXMLParserError: Error {
        case invalidPath
        case parsingError
    }
    
    case invalidPath
    case parsingError
    
    var errorValue: Error {
        switch self {
        case .invalidPath:
            return CBXMLParserError.invalidPath
        case .parsingError:
            return CBXMLParserError.parsingError
        }
    }
}
