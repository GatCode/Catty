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

class XMLAbstractTest: XCTestCase {

    override func setUp( ) {
        super.setUp()
        Util.activateTestMode(true)
    }

    override func tearDown() {
        super.tearDown()
    }

    func compareNewFileToOlderLanguageVersionFile(new: String, old: String) -> Bool {
        // implement when mapping serialization of Project is finished
        return false
    }

    func createAndCompareMappedObjcXMLFileFor(projectName: String) {

        // --------------------------------------------------
        // TODO: change getProjectForXML2 to getProjectForXML
        // --------------------------------------------------

        var project: Project?
        var xml: String?
        var readXml: String?

        getObjcProjectForXML2(xmlFile: projectName) { result, error in
            XCTAssertNil(error)
            project = result
        }

        XCTAssertNotNil(project)
        xml = CBXMLSerializer.shared.serializeProjectObjc(project: project!, xmlPath: nil, fileManager: nil)

        CBXMLSerializer.shared.writeXMLFile(filename: "file.xml", data: xml) { location, error in
            XCTAssertNil(error)
            print("XML file is located at: \(String(describing: location))!")
        }

        CBXMLSerializer.shared.readXMLFile(filename: "file.xml") { result, error in
            XCTAssertNil(error)
            readXml = result
        }

        var originalXML: String?
        getPathForXML(xmlFile: projectName) { path, error in
            XCTAssertNil(error)
            originalXML = try? String(contentsOfFile: path ?? "", encoding: .utf8)
        }

        XCTAssertTrue(diffXML(lhs: originalXML ?? "", rhs: readXml!))
    }

    func createAndCompareXMLFileFor(projectName: String) {

        // --------------------------------------------------
        // TODO: change getProjectForXML2 to getProjectForXML
        // --------------------------------------------------

        var project: CBProject?
        var xml: String?
        var readXml: String?

        getProjectForXML2(xmlFile: projectName) { result, error in
            XCTAssertNil(error)
            project = result
        }

        CBXMLSerializer.shared.createXMLDocument(project: project) { result, error in
            XCTAssertNil(error)
            xml = result
        }

        CBXMLSerializer.shared.writeXMLFile(filename: "file.xml", data: xml) { location, error in
            XCTAssertNil(error)
            print("XML file is located at: \(String(describing: location))!")
        }

        CBXMLSerializer.shared.readXMLFile(filename: "file.xml") { result, error in
            XCTAssertNil(error)
            readXml = result
        }

        var originalXML: String?
        getPathForXML(xmlFile: projectName) { path, error in
            XCTAssertNil(error)
            originalXML = try? String(contentsOfFile: path ?? "", encoding: .utf8)
        }

        XCTAssertTrue(diffXML(lhs: originalXML ?? "", rhs: readXml!))
    }

    func diffXML(lhs: String, rhs: String) -> Bool {
        var lhs = cleanAndSplitXMLWith(regex: "(<.*>)", xml: lhs)
        var rhs = cleanAndSplitXMLWith(regex: "(<.*>)", xml: rhs)
        guard let lhsLength = lhs?.count else { return false }
        guard let rhsLength = rhs?.count else { return false }

        let threshhold = 0.85 // to counteract eventual blank variables im xml
        lhs = Array(lhs?.prefix(Int(Double(lhsLength) * threshhold)) ?? [])
        rhs = Array(rhs?.prefix(Int(Double(rhsLength) * threshhold)) ?? [])

        if lhs == nil || rhs == nil || lhs!.isEmpty || rhs!.isEmpty { return false }

        for (left, right) in zip(lhs!, rhs!) {
            let lhs = String(left.filter { !" \n\t\r".contains($0) })
            let rhs = String(right.filter { !" \n\t\r".contains($0) })

            // hack to counteract AEXML attribute serialization order
            if lhs.contains("objecttype") || rhs.contains("objecttype") {
                continue
            }
            if lhs.contains("catrobatLanguageVersion") || rhs.contains("catrobatLanguageVersion") {
                continue
            }

            let numberOfChars = Double(lhs.count < rhs.count ? lhs.count : rhs.count)
            let threshhold = 0.8

            let lhsIndex = lhs.index(lhs.startIndex, offsetBy: Int(numberOfChars * threshhold))
            let rhsIndex = rhs.index(rhs.startIndex, offsetBy: Int(numberOfChars * threshhold))

            if lhs[..<lhsIndex] != rhs[..<rhsIndex] {
                print("ERROR XML DIFFS:\n\t\(lhs[..<lhsIndex])\n\t\(rhs[..<rhsIndex])")
                return false
            }

            print("SAME:\n\t\(lhs[..<lhsIndex])\n\t\(rhs[..<rhsIndex])")
        }

        return true
    }

    func cleanAndSplitXMLWith(regex: String, xml: String) -> [String]? {
        let xml = prepareXMLWithSpecialChars(xml: xml)
        guard let regex = try? NSRegularExpression(pattern: regex) else { return nil }
        let results = regex.matches(in: xml, range: NSRange(xml.startIndex..., in: xml))
        return results.map { String(xml[Range($0.range, in: xml)!]) }
    }

    func prepareXMLWithSpecialChars(xml: String) -> String {
        let specialChars: [String: String] = [
            "&quot;": "\"",
            "&amp;": "&",
            "&apos;": "'",
            "&lt;": "<",
            "&gt;": ">"
        ]

        var result = xml

        for char in specialChars {
            result = result.replacingOccurrences(of: char.key, with: char.value)
        }

        return result
    }

    func compareProject(firstProjectName: String, withProject secondProjectName: String) {

        // --------------------------------------------------
        // TODO: change getProjectForXML2 to getProjectForXML
        // --------------------------------------------------

        var project1: CBProject?
        var project2: CBProject?

        getProjectForXML2(xmlFile: firstProjectName) { project, error  in
            XCTAssertNil(error)
            project1 = project
        }

        getProjectForXML2(xmlFile: secondProjectName) { project, error in
            XCTAssertNil(error)
            project2 = project
        }

        XCTAssertNotNil(project1, "ERROR: project 1 is wrong or the XML file is not present!")
        XCTAssertNotNil(project2, "ERROR: project 2 is wrong or the XML file is not present!")
        XCTAssertTrue(project1 == project2)
    }

    func getProjectForXML2(xmlFile: String, completion: @escaping (CBProject?, XMLAbstractError?) -> Void) {

        // -----------------------------------------
        // TODO: change CBXMLParser2 to CBXMLParser
        // -----------------------------------------

        var xmlPath: String?
        getPathForXML(xmlFile: xmlFile) { path, error in
            if error != nil {
                completion(nil, error)
            }
            xmlPath = path
        }

        guard let path = xmlPath else { completion(nil, .invalidPath); return }

        let catrobatParser2 = CBXMLParser(path: path)
        if catrobatParser2 == nil {
            completion(nil, .unexpectedError)
        }

        catrobatParser2?.parseProject(completion: { error in
            if error != nil {
                completion(nil, .parsingError)
            }

            let project = catrobatParser2?.getProject()
            completion(project, nil)
        })
    }

    func getObjcProjectForXML2(xmlFile: String, completion: @escaping (Project?, XMLAbstractError?) -> Void) {

        // -----------------------------------------
        // TODO: change CBXMLParser2 to CBXMLParser
        // -----------------------------------------

        var xmlPath: String?
        getPathForXML(xmlFile: xmlFile) { path, error in
            if error != nil {
                completion(nil, error)
            }
            xmlPath = path
        }

        guard let path = xmlPath else { completion(nil, .invalidPath); return }

        let catrobatParser2 = CBXMLParser(path: path)
        if catrobatParser2 == nil {
            completion(nil, .unexpectedError)
        }

        catrobatParser2?.parseProject(completion: { error in
            if error != nil {
                completion(nil, .parsingError)
            }

            let project = catrobatParser2?.getProjectObjc()
            completion(project, nil)
        })
    }

    func getPathForXML(xmlFile: String, completion: @escaping (String?, XMLAbstractError?) -> Void) {
        let bundle = Bundle.init(for: self.classForCoder)
        guard let path = bundle.path(forResource: xmlFile, ofType: "xml") else {
            completion(nil, .invalidPath); return
        }
        completion(path, nil)
    }
}

enum XMLAbstractError: Error {
    case invalidPath
    case parsingError
    case unexpectedError
}
