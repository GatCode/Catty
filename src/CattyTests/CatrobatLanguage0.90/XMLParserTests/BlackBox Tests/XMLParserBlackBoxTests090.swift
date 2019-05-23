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

final class XMLParserBlackBoxTests090: XMLAbstractTest {

    func testDemonstration() {
        self.compareProject(firstProjectName: "Demonstration_09", withProject: "Demonstration_093")
    }

    func testDrinkMoreWater() {
        self.compareProject(firstProjectName: "Drink_more_water_09", withProject: "Drink_more_water_093")
    }

    func testMemory() {
        self.compareProject(firstProjectName: "Memory_09", withProject: "Memory_093")
    }

    func testPiano() {
        self.compareProject(firstProjectName: "Piano_09", withProject: "Piano_093")
    }

    func testPongStarter() {
        self.compareProject(firstProjectName: "Pong_Starter_09", withProject: "Pong_Starter_098")
    }

    func testPythagoreanTheorem() {
        self.compareProject(firstProjectName: "Pythagorean_Theorem_092", withProject: "Pythagorean_Theorem_093")
    }

    func testWordBalloonDemo() {
        self.compareProject(firstProjectName: "Word_balloon_demo_09", withProject: "Word_balloon_demo_093")
    }

    func testXRayPhone() {
        self.compareProject(firstProjectName: "X_Ray_phone_091", withProject: "X_Ray_phone_093")
    }

}
