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

final class XMLMappingGeneralTests: XMLMappingAbstractTests {

    func testBackAndForthMappings() {
        XCTAssertTrue(testBackAndForthMappingOfProjectToCBProject(filename: "EscapingChars_0994"))
        XCTAssertTrue(testBackAndForthMappingOfProjectToCBProject(filename: "Flap_Pac_Man_093"))
        XCTAssertTrue(testBackAndForthMappingOfProjectToCBProject(filename: "Flappy_v3.0_0992"))
        XCTAssertTrue(testBackAndForthMappingOfProjectToCBProject(filename: "Galaxy_War_098"))
        XCTAssertTrue(testBackAndForthMappingOfProjectToCBProject(filename: "Gossip_Girl_091"))
        XCTAssertTrue(testBackAndForthMappingOfProjectToCBProject(filename: "Minions__0994"))
        XCTAssertTrue(testBackAndForthMappingOfProjectToCBProject(filename: "Pong_Starter_0991"))
        XCTAssertTrue(testBackAndForthMappingOfProjectToCBProject(filename: "Rock_paper_scissors_093"))
        XCTAssertTrue(testBackAndForthMappingOfProjectToCBProject(filename: "SKYPASCAL_08"))
        XCTAssertTrue(testBackAndForthMappingOfProjectToCBProject(filename: "Test_Your_NFC_0994"))
        XCTAssertTrue(testBackAndForthMappingOfProjectToCBProject(filename: "Tic_Tac_Toe_Master_0993"))
        XCTAssertTrue(testBackAndForthMappingOfProjectToCBProject(filename: "Word_balloon_demo_095"))
        XCTAssertTrue(testBackAndForthMappingOfProjectToCBProject(filename: "X_Ray_phone_0992"))
        XCTAssertTrue(testBackAndForthMappingOfProjectToCBProject(filename: "CopyObjectsMapping"))
    }

    // MARK: - Legacy
    func testBackAndForthMappingsLegacy() {
        XCTAssertTrue(testBackAndForthMappingOfProjectToCBProject(filename: "Nyancat_1.0_091"))
        XCTAssertTrue(testBackAndForthMappingOfProjectToCBProject(filename: "Sensors_0991"))
        XCTAssertTrue(testBackAndForthMappingOfProjectToCBProject(filename: "Piano_098"))
        XCTAssertTrue(testBackAndForthMappingOfProjectToCBProject(filename: "Air_fight_0.5_097"))
        XCTAssertTrue(testBackAndForthMappingOfProjectToCBProject(filename: "ValidProjectAllBricks095"))
        XCTAssertTrue(testBackAndForthMappingOfProjectToCBProject(filename: "Demonstration_09"))
        XCTAssertTrue(testBackAndForthMappingOfProjectToCBProject(filename: "Airplane_with_shadow_0991"))
        XCTAssertTrue(testBackAndForthMappingOfProjectToCBProject(filename: "Memory_09"))
        XCTAssertTrue(testBackAndForthMappingOfProjectToCBProject(filename: "Pythagorean_Theorem_0991"))
        XCTAssertTrue(testBackAndForthMappingOfProjectToCBProject(filename: "ValidHeader0991"))
        XCTAssertTrue(testBackAndForthMappingOfProjectToCBProject(filename: "Sensors_0991"))
        XCTAssertTrue(testBackAndForthMappingOfProjectToCBProject(filename: "Minecraft_Work_In_Progress_092"))
        XCTAssertTrue(testBackAndForthMappingOfProjectToCBProject(filename: "WaitUntilBrick0991"))
        XCTAssertTrue(testBackAndForthMappingOfProjectToCBProject(filename: "Drink_more_water_097"))
        XCTAssertTrue(testBackAndForthMappingOfProjectToCBProject(filename: "Solar_System_v1.0_092"))
        XCTAssertTrue(testBackAndForthMappingOfProjectToCBProject(filename: "ValidProject0991"))
        XCTAssertTrue(testBackAndForthMappingOfProjectToCBProject(filename: "Compass_0.1_095"))
        XCTAssertTrue(testBackAndForthMappingOfProjectToCBProject(filename: "LedFlashBrick0991"))
        XCTAssertTrue(testBackAndForthMappingOfProjectToCBProject(filename: "Skydiving_Steve_092"))
        XCTAssertTrue(testBackAndForthMappingOfProjectToCBProject(filename: "LogicBricks_0991"))
        XCTAssertTrue(testBackAndForthMappingOfProjectToCBProject(filename: "PointToBrickWithoutSpriteObject"))
    }

}
