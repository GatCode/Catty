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

final class XMLParserBlackBoxTests091: XMLAbstractTest {

    func testAirFight() {
        self.compareProject(firstProjectName: "Air_fight_0.5_091", withProject: "Air_fight_0.5_093")
    }

    func testAirplaneWithShadow() {
        self.compareProject(firstProjectName: "Airplane_with_shadow_091", withProject: "Airplane_with_shadow_093")
    }

    func testCompass() {
        self.compareProject(firstProjectName: "Compass_0.1_091", withProject: "Compass_0.1_093")
    }

    func testFlapPacMan() {
        self.compareProject(firstProjectName: "Flap_Pac_Man_091", withProject: "Flap_Pac_Man_093")
    }

    func testGossipGirl() {
        self.compareProject(firstProjectName: "Gossip_Girl_091", withProject: "Gossip_Girl_093")
    }

    func testMinions() {
        self.compareProject(firstProjectName: "Minions__091", withProject: "Minions__093")
    }

    func testRockPaperScissors() {
        self.compareProject(firstProjectName: "Rock_paper_scissors_091", withProject: "Rock_paper_scissors_093")
    }

    func testTicTacToeMaster() {
        self.compareProject(firstProjectName: "Tic_Tac_Toe_Master_091", withProject: "Tic_Tac_Toe_Master_093")
    }

    func testXRayPhone() {
        self.compareProject(firstProjectName: "X_Ray_phone_091", withProject: "X_Ray_phone_093")
    }

}
