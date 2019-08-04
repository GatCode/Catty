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

enum CBXMLMappingFromObjc {

    static var userVariableList = [(UserVariable?, (Int, Int, Int))]() // contains local and global userVariables
    static var objectList = [(SpriteObject?, (Int, Int, Int))]()
    static var currentSerializationPosition = (0, 0, 0)
    static var globalVariableList = [(String, Bool)]() // isList: Bool
    static var localVariableList = [(SpriteObject?, [[UserVariable?: (Int, Int, Int)]])]()

    static func mapProjectToCBProject(project: Project) -> CBProject? {

        CBXMLMappingFromObjc.userVariableList.removeAll()
        CBXMLMappingFromObjc.objectList.removeAll()
        CBXMLMappingFromObjc.currentSerializationPosition = (0, 0, 0)
        CBXMLMappingFromObjc.globalVariableList.removeAll()
        CBXMLMappingFromObjc.localVariableList.removeAll()

        var mappedProject = CBProject()

        CBXMLMappingFromObjc.extractGlobalUserVariables(project: project)
        CBXMLMappingFromObjc.extractSpriteObjects(project: project)
        mappedProject.header = mapHeader(project: project)
        // settings need to be mapped for the CBL 0.994 upgrade
        mappedProject.scenes = CBXMLMappingFromObjc.mapScenesToCBProject(project: project)
        mappedProject.programVariableList = CBXMLMappingFromObjc.mapProgramVariableList(project: project)
        mappedProject.programListOfLists = CBXMLMappingFromObjc.mapProgramListOfLists(project: project)

        return mappedProject
    }
}

extension CBXMLMappingFromObjc {
    private static func extractGlobalUserVariables(project: Project) {
        project.programVariableList?.forEach { variable in
            if let variable = variable as? UserVariable, CBXMLMappingFromObjc.globalVariableList.contains(where: { $0.0 == variable.name && $0.1 == false }) == false {
                CBXMLMappingFromObjc.globalVariableList.append((variable.name, false))
            }
        }

        project.programListOfLists?.forEach { variable in
            if let variable = variable as? UserVariable, CBXMLMappingFromObjc.globalVariableList.contains(where: { $0.0 == variable.name && $0.1 == true }) == false {
                CBXMLMappingFromObjc.globalVariableList.append((variable.name, true))
            }
        }
    }

    private static func extractSpriteObjects(project: Project) {
        var counter = 0

        for object in project.objectList {
            if let obj = object as? SpriteObject {
                CBXMLMappingFromObjc.objectList.append((obj, (counter, 0, 0)))
            }
            counter += 1
        }
    }
}
