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

import AEXML

extension CBXMLSerializer2 {

    func addProgramVariableListTo(program: AEXMLElement, data: CBProgramVariableList?) {
        guard let data = data else { return }

        let programVariableList = program.addChild(name: "programVariableList")

        addUserVariablesTo(programVariableList: programVariableList, data: data.userVariable)
    }

    func addUserVariablesTo(programVariableList: AEXMLElement, data: [CBUserProgramVariable]?) {
        guard let data = data else { return }

        for userVar in data {
            if let ref = userVar.reference {
                programVariableList.addChild(name: "userVariable", value: userVar.value, attributes: ["reference": ref])
            } else if userVar.value != nil {
                programVariableList.addChild(name: "userVariable", value: userVar.value, attributes: ["reference": userVar.reference ?? ""])
            } else {
                programVariableList.addChild(name: "userVariable", value: "\n")
            }
        }
    }
}