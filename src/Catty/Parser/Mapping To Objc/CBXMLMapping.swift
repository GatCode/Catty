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

struct CBXMLMapping {

    static func mapCBProjectToProject(project: CBProject?) -> Project {

        let mappedProject = Project()

        // IMPORTANT: DO NOT CHANGE ORDER HERE!!
        mappedProject.header = CBXMLMapping.mapHeaderToHeader(input: project?.header)
        mappedProject.variables = CBXMLMapping.mapVariablesToVariableContrainer(input: project, project: mappedProject)
        mappedProject.objectList = CBXMLMapping.mapScenesToObjectList(input: project?.scenes, project: mappedProject)

        mappedProject.variables.allVariables()
        return mappedProject
    }
}

enum CBXMLMappingError: Error {
    case lookListMapError
    case soundListMapError
    case scriptListMapError

    case unsupportedScript
    case brickMappingError
    case unsupportedBrick

    case unknownError
}