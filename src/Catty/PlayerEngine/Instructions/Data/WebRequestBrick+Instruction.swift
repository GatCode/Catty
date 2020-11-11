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
            self.sendRequest(request: requestString) { response, error in
                guard let response = response else {
                    switch error.self {
                    case .request:
                        fatalError("Failed to load response")
                    case .timeout:
                        fatalError("Timeout")
                    default:
                        fatalError("Unexpected Error")
                    }
                }
                self.callbackSubmit(with: response, scheduler: scheduler)
            }
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

    func sendRequest(request: String, completion: @escaping (String?, WebRequestBrickError?) -> Void) {
        guard let url = URL(string: request) else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in

            let handleDataTaskCompletion: (Data?, URLResponse?, Error?) -> (response: String?, error: WebRequestBrickError?)
            handleDataTaskCompletion = { data, response, error in
                if let error = error as NSError?, error.code == NSURLErrorTimedOut {
                    return (nil, .timeout)
                }
                guard let response = response as? HTTPURLResponse else { return (nil, .unexpectedError) }
                guard let data = data, response.statusCode == 200, error == nil else {
                    return (nil, .request(error: error, statusCode: response.statusCode))
                }
                guard let stringResponse = String(data: data, encoding: .utf8) else { return (nil, .unexpectedError) }
                return (stringResponse, nil)
            }
            let result = handleDataTaskCompletion(data, response, error)
            DispatchQueue.main.async {
                completion(result.response, result.error)
            }
        }.resume()
    }

    enum WebRequestBrickError: Error {
        /// Indicates an error with the URLRequest.
        case request(error: Error?, statusCode: Int)
        /// Indicates an overflow of the MTLTextureDescriptor max length
        case timeout
        /// Indicates an unexpected error.
        case unexpectedError
    }
}
