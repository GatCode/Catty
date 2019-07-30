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

@objc class CBXMLSerializer: NSObject {

    static let shared = CBXMLSerializer()
    static var serializeInCBL991 = true

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
        if CBXMLSerializer.serializeInCBL991 == false {
            addSettingsTo(program: program)
            addScenesTo(program: program, data: project.scenes)
            addProgramVariableListTo(program: program, data: project.programVariableList)
            addProgramListOfListsTo(program: program, data: project.programListOfLists)
        } else {
            addObjectListTo(scene: program, data: project.scenes?.first?.objectList?.objects)
            addDataTo0991(scene: program, data: project.scenes?.first?.data, progVarList: project.programVariableList, progListOfLists: project.programListOfLists)
        }

        completion(writeRequest.xml, nil)
    }
}

// MARK: - Legacy Support
extension CBXMLSerializer {

    @objc func serializeProjectObjc(project: Project, xmlPath: String?, fileManager: CBFileManager?) -> String? {
        project.header.updateRelevantHeaderInfosBeforeSerialization()

        let mappedProject = CBXMLMappingFromObjc.mapProjectToCBProject(project: project)

        var resolvedXml: String?
        CBXMLSerializer.shared.createXMLDocument(project: mappedProject) { xml, _ in
            resolvedXml = xml
        }

        if xmlPath == nil {
            return resolvedXml
        }

        var error = false
        writeXMLFile(xmlPath: xmlPath, fileManager: fileManager, data: resolvedXml) { _, err in
            if err != nil {
                error = true
            }
        }

        return error ? nil : resolvedXml
    }
}

enum CBXMLSerializerError: Error {
    case invalidProject
    case serializationError
}
