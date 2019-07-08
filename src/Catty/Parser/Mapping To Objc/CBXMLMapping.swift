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

enum CBXMLMapping {

    static var mappingLookList = [Look]()
    static var mappingSoundList = [Sound]()
    static var mappingVariableList = [UserVariable]()
    static var localMappingVariableList = [UserVariable]()
    static var mappingBroadcastList = [String]()

    static func mapCBProjectToProject(project: CBProject?) -> Project? {

        var mappedProject = Project()
        CBXMLMapping.mappingLookList.removeAll()
        CBXMLMapping.mappingSoundList.removeAll()
        CBXMLMapping.mappingVariableList.removeAll()
        CBXMLMapping.mappingBroadcastList.removeAll()

        if let mappedHeader = mapHeader(project: project) {
            mappedProject.header = mappedHeader
        } else {
            return nil
        }

        if let mappedObjectList = mapObjectList(project: project, currentProject: &mappedProject) {
            mappedProject.objectList = mappedObjectList
        } else {
            return nil
        }

        if let mappedVariables = mapVariables(project: project, mappedProject: &mappedProject) {
            mappedProject.variables = mappedVariables
        } else {
            return nil
        }

        return mappedProject
    }
}
