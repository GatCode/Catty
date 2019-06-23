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
                let splittedReference = reference.split(separator: "/")
                var brickNr = 0
                var scriptNr = 0
                var objectNr = 0

                var fallbackCounter = 0
                for string in splittedReference.reversed() {
                    fallbackCounter += 1
                    if fallbackCounter == 2 {
                        brickNr = extractNumberInBacesFrom(string: String(string))
                    }
                    if fallbackCounter == 4 {
                        scriptNr = extractNumberInBacesFrom(string: String(string))
                    }
                    if fallbackCounter == 6 {
                        objectNr = extractNumberInBacesFrom(string: String(string))
                    }
                }

                if let objectList = CBProject?.scenes?.first?.objectList?.object, objectNr < objectList.count {
                    if let scriptList = objectList[objectNr].scriptList?.script, scriptNr < scriptList.count {
                        if let brickList = scriptList[scriptNr].brickList?.brick, brickNr < brickList.count {
                            if let uVar = brickList[brickNr].userList, !uVar.isEmpty {
                                let mappedUVar = mapUserVariableOrUserList(input: brickList[brickNr])
                                var alreadyInArray = false
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

        return NSMutableArray(array: arr)
    }
}
