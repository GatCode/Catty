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

final class XMLSerializerTests: XMLAbstractTest {

    func testReadWriteXMLFiles() {
        CBXMLSerializer.serializeInCBL991 = false
        createAndCompareXMLFileFor(projectName: "EscapingChars_0994")
        createAndCompareXMLFileFor(projectName: "Flap_Pac_Man_0994")
//        createAndCompareXMLFileFor(projectName: "Flappy_v3.0_0994")
//        createAndCompareXMLFileFor(projectName: "Galaxy_War_0994")
//        createAndCompareXMLFileFor(projectName: "Gossip_Girl_0994")
//        createAndCompareXMLFileFor(projectName: "Minions__0994")
//        createAndCompareXMLFileFor(projectName: "Pong_Starter_0994")
//        createAndCompareXMLFileFor(projectName: "Rock_paper_scissors_0994")
//        createAndCompareXMLFileFor(projectName: "Tic_Tac_Toe_Master_0994")
//        createAndCompareXMLFileFor(projectName: "Word_balloon_demo_0994")
//        createAndCompareXMLFileFor(projectName: "X_Ray_phone_0994")
    }

    func testObjcSerialization0991() {
        CBXMLSerializer.serializeInCBL991 = true
        createAndCompareMappedObjcXMLFileFor(projectName: "EscapingChars_0991")
        createAndCompareMappedObjcXMLFileFor(projectName: "Flap_Pac_Man_0991")
        createAndCompareMappedObjcXMLFileFor(projectName: "Flappy_v3.0_0991")
        createAndCompareMappedObjcXMLFileFor(projectName: "Galaxy_War_0991")
        createAndCompareMappedObjcXMLFileFor(projectName: "Gossip_Girl_0991")
        createAndCompareMappedObjcXMLFileFor(projectName: "Minions__0991")
        createAndCompareMappedObjcXMLFileFor(projectName: "Pong_Starter_0991")
        createAndCompareMappedObjcXMLFileFor(projectName: "Rock_paper_scissors_0991")
        createAndCompareMappedObjcXMLFileFor(projectName: "Tic_Tac_Toe_Master_0991")
        createAndCompareMappedObjcXMLFileFor(projectName: "Word_balloon_demo_0991")
        createAndCompareMappedObjcXMLFileFor(projectName: "X_Ray_phone_0991")
    }

    func testObjcSerialization0994() {
        CBXMLSerializer.serializeInCBL991 = false
        createAndCompareMappedObjcXMLFileFor(projectName: "EscapingChars_0994")
        createAndCompareMappedObjcXMLFileFor(projectName: "Flap_Pac_Man_0994")
        createAndCompareMappedObjcXMLFileFor(projectName: "Flappy_v3.0_0994")
        createAndCompareMappedObjcXMLFileFor(projectName: "Galaxy_War_0994")
        createAndCompareMappedObjcXMLFileFor(projectName: "Gossip_Girl_0994")
        createAndCompareMappedObjcXMLFileFor(projectName: "Minions__0994")
        createAndCompareMappedObjcXMLFileFor(projectName: "Pong_Starter_0994")
        createAndCompareMappedObjcXMLFileFor(projectName: "Rock_paper_scissors_0994")
        createAndCompareMappedObjcXMLFileFor(projectName: "Tic_Tac_Toe_Master_0994")
        createAndCompareMappedObjcXMLFileFor(projectName: "Word_balloon_demo_0994")
        createAndCompareMappedObjcXMLFileFor(projectName: "X_Ray_phone_0994")
    }
}
