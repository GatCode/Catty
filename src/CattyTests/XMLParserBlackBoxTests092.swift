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

final class XMLParserBlackBoxTests092: XMLAbstractTest {

    func testFlappy() {
        self.compareProject(firstProjectName: "Flappy_v3.0_092", withProject: "Flappy_v3.0_093")
    }

    func testGalaxyWar() {
        self.compareProject(firstProjectName: "Galaxy_War_092", withProject: "Galaxy_War_093")
    }

    func testMinecraftWorkInProgress() {
        self.compareProject(firstProjectName: "Minecraft_Work_In_Progress_092", withProject: "Minecraft_Work_In_Progress_093")
    }

    func testPythagoreanTheorem() {
        self.compareProject(firstProjectName: "Pythagorean_Theorem_092", withProject: "Pythagorean_Theorem_093")
    }

    func testSkydivingSteve() {
        self.compareProject(firstProjectName: "Skydiving_Steve_092", withProject: "Skydiving_Steve_093")
    }
}
