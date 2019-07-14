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

@objc class CBXMLSerializer2: NSObject {

    static let shared = CBXMLSerializer2()

    func createXMLDocument(project: CBProject?, completion: @escaping (String?, CBXMLSerializerError?) -> Void) {
        guard let project = project else { completion(nil, .invalidProject); return }

        var options = AEXMLOptions()
        options.documentHeader.version = 1.0
        options.documentHeader.encoding = "UTF-8"
        options.documentHeader.standalone = "yes"
        let writeRequest = AEXMLDocument(options: options)
        if writeRequest.error != nil { completion(nil, .serializationError) }

        let program = writeRequest.addChild(name: "program")

        addHeaderTo(program: program, data: project.header)
        addSettingsTo(program: program)
        addScenesTo(program: program, data: project.scenes)
        addProgramVariableListTo(program: program, data: project.programVariableList)
        addProgramListOfListsTo(program: program, data: project.programListOfLists)

        completion(writeRequest.xml, nil)
    }
}

// MARK: - Legacy Support
extension CBXMLSerializer2 {

    @objc func serializeProjectObjc(project: Project, xmlPath: String?, fileManager: CBFileManager?) -> String? {
        let mappedProject = CBXMLMappingFromObjc.mapProjectToCBProject(project: project)

        var resolvedXml: String?
        CBXMLSerializer2.shared.createXMLDocument(project: mappedProject) { xml, _ in
            resolvedXml = xml
        }

        if xmlPath == nil {
            return resolvedXml
        }

        writeXMLFile(xmlPath: xmlPath, fileManager: fileManager, data: resolvedXml) { path, error in
            return resolvedXml
        }

        return resolvedXml
    }
}

enum CBXMLSerializerError: Error {
    case invalidProject
    case serializationError
}
