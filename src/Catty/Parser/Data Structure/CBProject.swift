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

struct CBProject: XMLIndexerDeserializable, Equatable {
    let header: CBHeader?
    let scenes: [CBProjectScene]?
    let programVariableList: CBProgramVariableList?
    let programListOfLists: CBProgramListOfLists?

    static func deserialize(_ node: XMLIndexer) throws -> CBProject {

        var tmpScenes: [CBProjectScene]?
        var tmpProgramVariableList: CBProgramVariableList?
        tmpScenes = try node["scenes"].value()
        tmpProgramVariableList = try node["programVariableList"].value()

        if tmpScenes == nil {
            tmpScenes = [CBProjectScene]()
            var objectList: CBObjectList?
            var objectVariableList: CBObjectVariableList?
            var objectListOfList: CBObjectListofList?
            var userBrickVariableList: CBUserBrickVariableList?

            objectList = try node["objectList"].value()
            objectVariableList = try node["variables"]["objectVariableList"].value()
            if objectVariableList == nil {
                objectVariableList = try node["data"]["objectVariableList"].value()
            }

            objectListOfList = try node["data"]["objectListOfList"].value()
            userBrickVariableList = try node["data"]["userBrickVariableList"].value()

            // TODO: node["data"]["programListOfLists"] and node["data"]["programVariableList"]

            let data = CBProjectData(objectListOfList: objectListOfList, objectVariableList: objectVariableList, userBrickVariableList: userBrickVariableList)

            tmpScenes!.append(CBProjectScene(name: nil, objectList: objectList, data: data, originalWidth: nil, originalHeight: nil))

            tmpProgramVariableList = try node["variables"]["programVariableList"].value()

            if tmpProgramVariableList == nil {
                tmpProgramVariableList = try node["data"]["programVariableList"].value()
            }
        }

        return try CBProject(
            header: node["header"].value(),
            scenes: tmpScenes,
            programVariableList: tmpProgramVariableList,
            programListOfLists: node["programListOfLists"].value()
        )
    }

    static func == (lhs: CBProject, rhs: CBProject) -> Bool {
        return
            lhs.header == rhs.header &&
            lhs.scenes == rhs.scenes
    }
}
