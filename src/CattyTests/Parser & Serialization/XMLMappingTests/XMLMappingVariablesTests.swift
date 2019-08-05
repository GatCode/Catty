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

import XCTest

@testable import Pocket_Code

final class XMLMappingVariablesTests: XMLMappingAbstractTests {

    func testProgramVariableListsAreEqual() {
        let cbProject = createExtendedCBProject()
        let project = CBXMLMappingToObjc.mapCBProjectToProject(project: cbProject)

        let cbProgramVariableListCount = cbProject.programVariableList?.userVariable?.count
        let mappedProgramVariableListCount = project?.programVariableList?.count
        XCTAssertEqual(cbProgramVariableListCount, mappedProgramVariableListCount)

        for vIdx in 0..<cbProgramVariableListCount! {
            let cbVar = cbProject.programVariableList?.userVariable?[vIdx]
            let mappedVar = project?.programVariableList?[vIdx] as? UserVariable

            XCTAssertEqual(cbVar?.value, mappedVar?.name)
        }
    }

    func testProgramVariableListsWithReferencesAreEqual() {
        let resolvedProject = createExtendedCBProjectWithReferencedUserVariable()
        let cbProject = resolvedProject.0
        let referencedUserVariable = resolvedProject.1

        let project = CBXMLMappingToObjc.mapCBProjectToProject(project: cbProject)

        XCTAssertEqual((project?.programVariableList?[0] as? UserVariable)?.name, referencedUserVariable)
    }

    func testProgramListOfListsAreEqual() {
        let cbProject = createExtendedCBProject()
        let project = CBXMLMappingToObjc.mapCBProjectToProject(project: cbProject)

        let cbProgramListOfListsCount = cbProject.programListOfLists?.list?.count
        let mappedProgramListOfListsCount = project?.programListOfLists?.count
        XCTAssertEqual(cbProgramListOfListsCount, mappedProgramListOfListsCount)

        for vIdx in 0..<cbProgramListOfListsCount! {
            let cbVar = cbProject.programListOfLists?.list?[vIdx]
            let mappedVar = project?.programListOfLists?[vIdx] as? UserVariable

            XCTAssertEqual(cbVar?.value, mappedVar?.name)
        }
    }

    func testProgramListOfListsWithReferencesAreEqual() {
        let resolvedProject = createExtendedCBProjectWithReferencedUserVariable()
        let cbProject = resolvedProject.0
        let referencedUserVariable = resolvedProject.1

        let project = CBXMLMappingToObjc.mapCBProjectToProject(project: cbProject)

        XCTAssertEqual((project?.programListOfLists?[0] as? UserVariable)?.name, referencedUserVariable)
    }
}
