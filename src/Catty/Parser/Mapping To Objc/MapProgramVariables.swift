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

    static func mapVariablesToVariableContrainer(input: CBProject?, project: Project) -> VariablesContainer {
        let varContainer = VariablesContainer()

        let programVariablesList = getProgramVariableListFrom(CBProject: input, project: project)
        varContainer.programVariableList = programVariablesList

        let programListOfLists = getProgramListofListsFrom(CBProject: input, project: project)
        varContainer.programListOfLists = programListOfLists

        let objectVariableMap = getObjectVariableMapFrom(project: input)
        let objectVariableList = getObjectVariableListFrom(map: objectVariableMap, cbProject: input, project: project)
        varContainer.objectVariableList = objectVariableList

        let objectListMap = getObjectListMapFrom(project: input)
        let objectListOfLists = getObjectListOfListsFrom(map: objectListMap, cbProject: input, project: project)
        varContainer.objectListOfLists = objectListOfLists

        return varContainer
    }

    static func extractNumberInBacesFrom(string: String) -> Int {
        var firstDigit: Int?
        var secondDigit: Int?
        var thirdDigit: Int?

        let firstDigitRange = string.range(of: "[(0-9)*]", options: .regularExpression)

        if let fdr = firstDigitRange {
            firstDigit = Int(string[fdr])

            let secondPartOfString = string[Range(uncheckedBounds: (lower: fdr.upperBound, upper: string.endIndex))]
            let secondDigitRange = secondPartOfString.range(of: "[(0-9)*]", options: .regularExpression)

            if let sdr = secondDigitRange {
                secondDigit = Int(string[sdr])

                let thirdPartOfString = string[Range(uncheckedBounds: (lower: sdr.upperBound, upper: string.endIndex))]
                let thirdDigitRange = thirdPartOfString.range(of: "[(0-9)*]", options: .regularExpression)

                if let tdr = thirdDigitRange {
                    thirdDigit = Int(string[tdr])
                }
            }
        }

        if let first = firstDigit, let second = secondDigit, let third = thirdDigit {
            return first * 100 + second * 10 + third - 1
        } else if let first = firstDigit, let second = secondDigit {
            return first * 10 + second - 1
        } else if let first = firstDigit {
            return first - 1
        } else {
            return 0
        }
    }
}
