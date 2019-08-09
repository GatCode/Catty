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

final class VariableTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func testAddObjectVariable() {
        let project = Project()
        let firstScene = project.scenes.firstObject as? Scene

        let objectA = SpriteObject(scene: project.scenes.firstObject as? Scene)!
        objectA.name = "testObjectA"
        firstScene?.addObject(toObjectList: objectA)

        let objectB = SpriteObject(scene: project.scenes.firstObject as? Scene)!
        objectB.name = "testObjectB"
        firstScene?.addObject(toObjectList: objectB)

        let userVariable = UserVariable()
        userVariable.name = "testName"

        XCTAssertEqual(0, project.allVariables(for: firstScene)?.count)
        XCTAssertEqual(0, project.allVariables(for: objectA)?.count)
        XCTAssertEqual(0, project.allVariables(for: objectB)?.count)

        var result = project.addObjectVariable(userVariable, for: objectA, to: firstScene)
        XCTAssertTrue(result)

        XCTAssertEqual(1, project.allVariables(for: firstScene)?.count)
        XCTAssertEqual(1, project.allVariables(for: objectA)?.count)
        XCTAssertEqual(0, project.allVariables(for: objectB)?.count)

        result = project.addObjectVariable(userVariable, for: objectA, to: firstScene)
        XCTAssertFalse(result)

        result = project.addObjectVariable(userVariable, for: objectB, to: firstScene)
        XCTAssertTrue(result)

        XCTAssertEqual(2, project.allVariables(for: firstScene)?.count)
        XCTAssertEqual(1, project.allVariables(for: objectA)?.count)

        XCTAssertEqual(1, project.allVariables(for: objectB)?.count)
    }

    func testAddObjectList() {
        let container = Project()
        let firstScene = container.scenes.firstObject as? Scene

        let objectA = SpriteObject(scene: container.scenes.firstObject as? Scene)!
        objectA.name = "testObjectA"
        firstScene?.addObject(toObjectList: objectA)

        let objectB = SpriteObject(scene: container.scenes.firstObject as? Scene)!
        objectB.name = "testObjectB"
        firstScene?.addObject(toObjectList: objectB)

        let list = UserVariable()
        list.name = "testName"
        list.isList = true

        XCTAssertEqual(0, container.allLists(for: firstScene)?.count)
        XCTAssertEqual(0, container.allLists(for: objectA)?.count)
        XCTAssertEqual(0, container.allLists(for: objectB)?.count)

        var result = container.addObjectList(list, for: objectA, to: firstScene)
        XCTAssertTrue(result)

        XCTAssertEqual(1, container.allLists(for: firstScene)?.count)
        XCTAssertEqual(1, container.allLists(for: objectA)?.count)
        XCTAssertEqual(0, container.allLists(for: objectB)?.count)

        result = container.addObjectList(list, for: objectA, to: firstScene)
        XCTAssertFalse(result)

        result = container.addObjectList(list, for: objectB, to: firstScene)
        XCTAssertTrue(result)

        XCTAssertEqual(2, container.allLists(for: firstScene)?.count)
        XCTAssertEqual(1, container.allLists(for: objectA)?.count)
        XCTAssertEqual(1, container.allLists(for: objectB)?.count)
    }
}