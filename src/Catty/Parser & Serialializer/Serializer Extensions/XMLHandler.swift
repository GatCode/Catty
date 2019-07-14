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

extension CBXMLSerializer {

    // MARK: - Read XML File
    func readXMLFile(filename: String, completion: @escaping (String?, CBXMLSerializerXMLHandlerError?) -> Void) {

        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {

            let filePath = dir.appendingPathComponent(filename)

            do {
                let result = try String(contentsOf: filePath, encoding: .utf8)
                completion(result, nil)
            } catch {
                completion(nil, CBXMLSerializerXMLHandlerError.readError)
            }
        } else {
            completion(nil, CBXMLSerializerXMLHandlerError.invalidDirectory)
        }
    }

    // MARK: - Write XML File
    func writeXMLFile(filename: String, data: String?, completion: @escaping (String?, CBXMLSerializerXMLHandlerError?) -> Void) {

        guard let data = data else { completion(nil, .invalidData); return }

        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {

            let filePath = dir.appendingPathComponent(filename)

            do {
                try data.write(to: filePath, atomically: false, encoding: .utf8)
                completion(dir.absoluteString, nil)
            } catch {
                completion(nil, CBXMLSerializerXMLHandlerError.writeError)
            }
        } else {
            completion(nil, CBXMLSerializerXMLHandlerError.invalidDirectory)
        }
    }

    func writeXMLFile(xmlPath: String?, fileManager: CBFileManager?, data: String?, completion: @escaping (String?, CBXMLSerializerXMLHandlerError?) -> Void) {
        guard let data = data else { completion(nil, CBXMLSerializerXMLHandlerError.writeError); return }
        guard let stringPath = xmlPath else { completion(nil, CBXMLSerializerXMLHandlerError.writeError); return }
        let xmlPath = URL(fileURLWithPath: stringPath)

        do {
            try data.write(to: xmlPath, atomically: true, encoding: .utf8)
            completion(stringPath, nil)
        } catch {
            completion(nil, CBXMLSerializerXMLHandlerError.writeError)
        }
    }
}

enum CBXMLSerializerXMLHandlerError: Error {
    case invalidData
    case invalidDirectory
    case writeError
    case readError
}
