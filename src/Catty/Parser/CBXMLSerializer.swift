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

class CBXMLSerializer2 {

    static let shared = CBXMLSerializer2()

    func createXMLDocument(project: CBProject?, completion: @escaping (String?, CBXMLSerializerError?) -> Void) {
        guard let project = project else { completion(nil, .invalidProject); return }

        var options = AEXMLOptions()
        options.documentHeader.version = 1.0
        options.documentHeader.encoding = "UTF-8"
        options.documentHeader.standalone = "yes"
        let writeRequest = AEXMLDocument(options: options)

        let program = writeRequest.addChild(name: "program")

        // TODO: proper error handling!
        addHeaderTo(program: program, data: project.header)
        addSettingsTo(program: program)
        addScenesTo(program: program, data: project.scenes)
        addProgramVariableListTo(program: program, data: project.programVariableList)
        addProgramListOfListsTo(program: program)

        let cleanedXML = cleanXMLFromSpecialChars(xml: writeRequest.xml)
        completion(cleanedXML, nil)
    }
}

func cleanXMLFromSpecialChars(xml: String) -> String {
    let specialChars: [String: String] = [
        "&quot;": "\"",
        "&amp;": "&",
        "&apos;": "'",
        "&lt;": "<",
        "&gt;": ">"
    ]

    var result = xml

    for char in specialChars {
        result = result.replacingOccurrences(of: char.key, with: char.value)
    }

    return result
}

enum CBXMLSerializerError: Error {
    case invalidProject
    case serializationError
}
