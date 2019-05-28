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

final class XMLParserTests: XMLAbstractTest {

    func test080VS093() {
        self.compareProject(firstProjectName: "SKYPASCAL_08", withProject: "SKYPASCAL_093")
    }

    func testAllLanguageVersionsFlapPacMan() {
        self.compareProject(firstProjectName: "Flap_Pac_Man_091", withProject: "Flap_Pac_Man_093")
        self.compareProject(firstProjectName: "Flap_Pac_Man_093", withProject: "Flap_Pac_Man_096")
        self.compareProject(firstProjectName: "Flap_Pac_Man_096", withProject: "Flap_Pac_Man_097")
        self.compareProject(firstProjectName: "Flap_Pac_Man_097", withProject: "Flap_Pac_Man_098")
        self.compareProject(firstProjectName: "Flap_Pac_Man_098", withProject: "Flap_Pac_Man_0991")
        self.compareProject(firstProjectName: "Flap_Pac_Man_0991", withProject: "Flap_Pac_Man_0992")
        self.compareProject(firstProjectName: "Flap_Pac_Man_0992", withProject: "Flap_Pac_Man_0993")
        self.compareProject(firstProjectName: "Flap_Pac_Man_0993", withProject: "Flap_Pac_Man_0994")
    }

    func testAllLanguageVersionsFlappy() {
        self.compareProject(firstProjectName: "Flappy_v3.0_092", withProject: "Flappy_v3.0_093")
        self.compareProject(firstProjectName: "Flappy_v3.0_093", withProject: "Flappy_v3.0_095")
        self.compareProject(firstProjectName: "Flappy_v3.0_095", withProject: "Flappy_v3.0_096")
        self.compareProject(firstProjectName: "Flappy_v3.0_096", withProject: "Flappy_v3.0_097")
        self.compareProject(firstProjectName: "Flappy_v3.0_097", withProject: "Flappy_v3.0_098")
        self.compareProject(firstProjectName: "Flappy_v3.0_098", withProject: "Flappy_v3.0_0991")
        self.compareProject(firstProjectName: "Flappy_v3.0_0991", withProject: "Flappy_v3.0_0992")
        self.compareProject(firstProjectName: "Flappy_v3.0_0992", withProject: "Flappy_v3.0_0993")
        self.compareProject(firstProjectName: "Flappy_v3.0_0993", withProject: "Flappy_v3.0_0994")
    }

    func testAllLanguageVersionsGalaxyWar() {
        self.compareProject(firstProjectName: "Galaxy_War_092", withProject: "Galaxy_War_093")
        self.compareProject(firstProjectName: "Galaxy_War_093", withProject: "Galaxy_War_095")
        self.compareProject(firstProjectName: "Galaxy_War_095", withProject: "Galaxy_War_096")
        self.compareProject(firstProjectName: "Galaxy_War_096", withProject: "Galaxy_War_097")
        self.compareProject(firstProjectName: "Galaxy_War_097", withProject: "Galaxy_War_098")
        self.compareProject(firstProjectName: "Galaxy_War_098", withProject: "Galaxy_War_0991")
        self.compareProject(firstProjectName: "Galaxy_War_0991", withProject: "Galaxy_War_0992")
        self.compareProject(firstProjectName: "Galaxy_War_0992", withProject: "Galaxy_War_0993")
        self.compareProject(firstProjectName: "Galaxy_War_0993", withProject: "Galaxy_War_0994")
    }

    func testAllLanguageVersionsPongStarter() {
        self.compareProject(firstProjectName: "Pong_Starter_09", withProject: "Pong_Starter_093")
        self.compareProject(firstProjectName: "Pong_Starter_093", withProject: "Pong_Starter_095")
        self.compareProject(firstProjectName: "Pong_Starter_095", withProject: "Pong_Starter_096")
        self.compareProject(firstProjectName: "Pong_Starter_096", withProject: "Pong_Starter_097")
        self.compareProject(firstProjectName: "Pong_Starter_097", withProject: "Pong_Starter_098")
        self.compareProject(firstProjectName: "Pong_Starter_098", withProject: "Pong_Starter_0991")
        self.compareProject(firstProjectName: "Pong_Starter_0991", withProject: "Pong_Starter_0992")
        self.compareProject(firstProjectName: "Pong_Starter_0992", withProject: "Pong_Starter_0993")
        self.compareProject(firstProjectName: "Pong_Starter_0993", withProject: "Pong_Starter_0994")
    }

    func testAllLanguageVersionsXRayPhone() {
        self.compareProject(firstProjectName: "X_Ray_phone_091", withProject: "X_Ray_phone_093")
        self.compareProject(firstProjectName: "X_Ray_phone_093", withProject: "X_Ray_phone_095")
        self.compareProject(firstProjectName: "X_Ray_phone_095", withProject: "X_Ray_phone_096")
        self.compareProject(firstProjectName: "X_Ray_phone_096", withProject: "X_Ray_phone_097")
        self.compareProject(firstProjectName: "X_Ray_phone_097", withProject: "X_Ray_phone_098")
        self.compareProject(firstProjectName: "X_Ray_phone_098", withProject: "X_Ray_phone_0991")
        self.compareProject(firstProjectName: "X_Ray_phone_0991", withProject: "X_Ray_phone_0992")
        self.compareProject(firstProjectName: "X_Ray_phone_0992", withProject: "X_Ray_phone_0993")
        self.compareProject(firstProjectName: "X_Ray_phone_0993", withProject: "X_Ray_phone_0994")
    }
}
