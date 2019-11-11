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

extension CBXMLMappingToObjc {

    static func mapFormulaListToBrick(input: CBBrick?) -> NSMutableArray? {
        var formulaList = [Formula]()

        if let formulas = input?.formulaList?.formulas {
            addFormulaToList(formulas: formulas, formulaList: &formulaList)
        } else if let formulas = input?.formulaTree?.formulas {
            addFormulaToList(formulas: formulas, formulaList: &formulaList)
        } else {
            return nil
        }

        return NSMutableArray(array: formulaList)
    }

    static func addFormulaToList(formulas: [CBFormula], formulaList: inout [Formula]) {
        for formula in formulas {
            let mappedFormula = mapCBFormulaToFormula(input: formula)
            if formulaList.contains(mappedFormula) == false {
                formulaList.append(mappedFormula)
            }
        }
    }

    static func mapCBFormulaToFormula(input: CBFormula?) -> Formula {
        let formula = Formula()
        guard let input = input else { return formula }

        var elementType = ElementType.NUMBER
        switch input.type {
        case "NUMBER":
            elementType = ElementType.NUMBER
        case "OPERATOR":
            elementType = ElementType.OPERATOR
        case "USER_VARIABLE":
            elementType = ElementType.USER_VARIABLE
        case "USER_LIST":
            elementType = ElementType.USER_LIST
        case "FUNCTION":
            elementType = ElementType.FUNCTION
        case "SENSOR":
            elementType = ElementType.SENSOR
        case "BRACKET":
            elementType = ElementType.BRACKET
        default:
            elementType = ElementType.STRING
        }

        let formulaTree = FormulaElement(elementType: elementType, value: input.value, leftChild: nil, rightChild: nil, parent: nil)

        if let leftChild = input.leftChild, let tree = formulaTree {
            formulaTree?.leftChild = mapCBLRChildToFormulaTree(input: leftChild, tree: tree)
        }

        if let rightChild = input.rightChild, let tree = formulaTree {
            formulaTree?.rightChild = mapCBLRChildToFormulaTree(input: rightChild, tree: tree)
        }

        formula.formulaTree = formulaTree
        formula.category = input.category
        return formula
    }

    static func mapCBLRChildToFormulaTree(input: CBLRChild?, tree: FormulaElement) -> FormulaElement? {
        guard let input = input else { return nil }
        let child = FormulaElement(type: input.type, value: input.value, leftChild: nil, rightChild: nil, parent: nil)
        child?.parent = tree

        if let leftChild = input.leftChild.first, leftChild != nil, let ch = child {
            let leftChild = mapCBLRChildToFormulaTree(input: leftChild, tree: ch)
            child?.leftChild = leftChild
        }

        if let rightChild = input.rightChild.first, rightChild != nil, let ch = child {
            let rightChild = mapCBLRChildToFormulaTree(input: rightChild, tree: ch)
            child?.rightChild = rightChild
        }

        return child
    }

    static func mapDestinations(input: CBBrick?, xDestination: Bool) -> NSMutableArray? {
        var formulaList = [Formula]()

        if let formulas = xDestination ? input?.xDestination?.formulas : input?.yDestination?.formulas {
            addFormulaToList(formulas: formulas, formulaList: &formulaList)
        }

        return NSMutableArray(array: formulaList)
    }
}
