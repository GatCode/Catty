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

    static func getProgramListofListsFrom(CBProject: CBProject?, project: Project) -> NSMutableArray {
        guard let userVariables = CBProject?.programListOfLists?.list else { return NSMutableArray() }
        var arr = [UserVariable]()

        for variable in userVariables {
            if let reference = variable.reference {
                let abstractNumbers = extractAbstractNumbersFrom(reference: reference, project: CBProject)
                let brickNr = abstractNumbers.2
                let scriptNr = abstractNumbers.1
                let objectNr = abstractNumbers.0

                if let objectList = CBProject?.scenes?.first?.objectList?.object, objectNr < objectList.count {
                    if let scriptList = objectList[objectNr].scriptList?.script, scriptNr < scriptList.count {
                        if let brickList = scriptList[scriptNr].brickList?.brick, brickNr < brickList.count {
                            if let uVar = brickList[brickNr].userList, !uVar.isEmpty {
                                let mappedUVar = mapUserVariableOrUserList(input: brickList[brickNr])
                                var alreadyInArray = false
                                if let mappedUVar = mappedUVar {
                                    for obj in arr where obj.name == mappedUVar.name {
                                        alreadyInArray = true
                                    }
                                    if alreadyInArray == false {
                                        arr.append(mappedUVar)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        return NSMutableArray(array: arr)
    }
}
