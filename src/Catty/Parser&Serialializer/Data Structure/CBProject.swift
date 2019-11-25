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
    var header: CBHeader?
    var scenes: [CBProjectScene]?
    var programVariableList: CBProgramVariableList?
    var programListOfLists: CBProgramListOfLists?

    init(header: CBHeader? = nil,
         scenes: [CBProjectScene]? = nil,
         programVariableList: CBProgramVariableList? = nil,
         programListOfLists: CBProgramListOfLists? = nil) {
        self.header = header
        self.scenes = scenes
        self.programVariableList = programVariableList
        self.programListOfLists = programListOfLists
    }

    static func deserialize(_ node: XMLIndexer) throws -> CBProject {
        var tmpScenes: [CBProjectScene]?
        var tmpProgramVariableList: CBProgramVariableList?
        var tmpProgramListOfLists: CBProgramListOfLists?
        tmpScenes = try node["scenes"].value()
        tmpProgramListOfLists = try node["programListOfLists"].value()
        tmpProgramVariableList = try node["programVariableList"].value()

        if tmpScenes == nil {
            tmpScenes = [CBProjectScene]()
            var objectList: CBObjectList?
            var objectListOfList: CBObjectListofList?
            var objectVariableList: CBObjectVariableList?
            var userBrickVariableList: CBUserBrickVariableList?

            objectList = try node["objectList"].value()

            objectListOfList = try node["variables"]["objectListOfList"].value()
            if objectListOfList == nil {
                objectListOfList = try node["data"]["objectListOfList"].value()
            }

            objectVariableList = try node["variables"]["objectVariableList"].value()
            if objectVariableList == nil {
                objectVariableList = try node["data"]["objectVariableList"].value()
            }

            tmpProgramListOfLists = try node["variables"]["programListOfLists"].value()
            if tmpProgramListOfLists == nil {
                tmpProgramListOfLists = try node["data"]["programListOfLists"].value()
            }

            tmpProgramVariableList = try node["variables"]["programVariableList"].value()
            if tmpProgramVariableList == nil {
                tmpProgramVariableList = try node["data"]["programVariableList"].value()
            }

            userBrickVariableList = try node["data"]["userBrickVariableList"].value()

            let data = CBProjectData(objectListOfList: objectListOfList, objectVariableList: objectVariableList, userBrickVariableList: userBrickVariableList)

            tmpScenes!.append(CBProjectScene(name: nil, objectList: objectList, data: data, originalWidth: nil, originalHeight: nil))
        }

        return try CBProject(
            header: node["header"].value(),
            scenes: tmpScenes,
            programVariableList: tmpProgramVariableList,
            programListOfLists: tmpProgramListOfLists
        )
    }

    static func == (lhs: CBProject, rhs: CBProject) -> Bool {
        return
            lhs.header == rhs.header &&
            lhs.scenes == rhs.scenes
    }
}
