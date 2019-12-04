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

extension CBXMLMappingFromObjc {

    static func mapFormulaList(formulas: [Formula?]) -> CBFormulaList? {
        var mappedFormulas = [CBFormula]()

        for formula in formulas {
            if let mappedFormula = mapFormula(formula: formula) {
                mappedFormulas.append(mappedFormula)
            }
        }

        return CBFormulaList(formulas: mappedFormulas)
    }

    static func mapFormula(formula: Formula?) -> CBFormula? {
        guard let formula = formula else { return nil }
        guard let parentElement = formula.formulaTree else { return nil }

        let type = parentElement.string(for: parentElement.type)
        let value = parentElement.value
        let category = formula.category
        let left = mapFormulaChild(formulaElement: parentElement.leftChild)
        let right = mapFormulaChild(formulaElement: parentElement.rightChild)

        let mappedFormula = CBFormula(type: type, value: value, category: category, leftChild: left, rightChild: right)

        return mappedFormula
    }

    static func mapFormulaChild(formulaElement: FormulaElement?) -> CBLRChild? {
        guard let formulaElement = formulaElement else { return nil }

        var mappedChild = CBLRChild()
        mappedChild.type = formulaElement.string(for: formulaElement.type)
        mappedChild.value = formulaElement.value
        mappedChild.leftChild = [mapFormulaChild(formulaElement: formulaElement.leftChild)]
        mappedChild.rightChild = [mapFormulaChild(formulaElement: formulaElement.rightChild)]

        return mappedChild
    }

}
