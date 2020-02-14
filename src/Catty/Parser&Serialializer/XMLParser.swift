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

import Fuzi

@objc class XMLParser: NSObject {
    
    fileprivate var xmlPath: String = ""
    
//    var responseMessages = ["objectList": NSMutableArray<SpriteObject*>,
//        403: "Access forbidden",
//        404: "File not found",
//        500: "Internal server error"]
//
    @objc required init?(path: String) {
        if path.isEmpty {
            return nil
        }
        xmlPath = path
    }
    
    @objc func parseAndCreateProject() -> Project? {
        
        guard let xml = try? String(contentsOfFile: xmlPath) else { return nil }
        guard let document = try? XMLDocument(string: xml, encoding: String.Encoding.utf8) else { return nil }
        
        if let root = document.root {
          parse(element: root)
        }
        
        return nil
    }
    
    func parse(element: XMLElement) {
                
        for child in element.children where child == "objectList {
            parse(element: child)
        }
    }
}
