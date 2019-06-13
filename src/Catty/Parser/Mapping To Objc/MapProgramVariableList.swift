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

extension CBXMLMapping {

    static func mapVariablesToVariableContrainer(input: CBProject?) -> VariablesContainer {
        let varContainer = VariablesContainer()
        guard let input = input else { return varContainer }

        var programVaiableList = [UserVariable]()

        if let objectList = input.scenes?.first?.objectList?.object {
            for object in objectList {
                if let scripts = object.scriptList?.script {
                    for script in scripts {
                        if let bricks = script.brickList?.brick {
                            for brick in bricks {
                                let userVarToAppend = mapUserVariableOrUserList(input: brick)
                                if userVarToAppend.name.isEmpty == false, programVaiableList.contains(userVarToAppend) == false {
                                    programVaiableList.append(userVarToAppend)
                                }
                            }
                        }
                    }
                }
            }
        }

        varContainer.programVariableList = NSMutableArray(array: programVaiableList)

        return varContainer
    }
}
