/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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

extension WebRequestBrick: CBInstructionProtocol {

    @nonobjc func instruction() -> CBInstruction {
        guard let request = self.request else { fatalError("Unexpected found nil.") }
        guard let displayString = request.getDisplayString() else { fatalError("Unexpected found nil.") }

        var requestString = displayString
        if requestString.hasPrefix("'") {
            requestString = String(requestString.dropFirst())
        }
        if requestString.hasSuffix("'") {
            requestString = String(requestString.dropLast())
        }

        return CBInstruction.waitExecClosure { _, scheduler in
            guard let url = URL(string: requestString) else { return }
            URLSession.shared.dataTask(with: url) {(data, response, error) in
                guard let data = data else { return }
                guard let response = String(data: data, encoding: .utf8) else { return }
                self.callbackSubmit(with: response, scheduler: scheduler)
            }.resume()
            scheduler.pause()
        }
    }
    
    func callbackSubmit(with input: String, scheduler: CBSchedulerProtocol) {
        guard let userVariable = self.userVariable else { fatalError("Unexpected found nil.") }
        userVariable.value = input
        DispatchQueue.main.async {
          scheduler.resume()
        }
    }
}
