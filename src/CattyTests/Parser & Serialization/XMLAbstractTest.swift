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

    func createAndCompareMappedObjcXMLFileFor(projectName: String) {
        var project: Project?
        var xml: String?
        var readXml: String?

        getObjcProjectForXML(xmlFile: projectName) { result, error in
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
        var project: CBProject?
        var xml: String?
        var readXml: String?

        getProjectForXML(xmlFile: projectName) { result, error in
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

            // hack to counteract AEXML attribute serialization order and changing header properties
            var ignoreWord = false
            let attributesToIgnore = [
                "objecttype",
                "applicationBuildName",
                "applicationBuildNumber",
                "applicationVersion",
                "deviceName",
                "mediaLicense",
                "platform",
                "catrobatLanguageVersion",
                "LoopEndBrick",
                "formula",
                "type",
                "value"
            ]
            for attribute in attributesToIgnore {
                if lhs.contains(attribute) || rhs.contains(attribute) {
                    ignoreWord = true
                }
            }
            if ignoreWord {
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

            // NOTE: commented out to improve test speed
            // print("SAME:\n\t\(lhs[..<lhsIndex])\n\t\(rhs[..<rhsIndex])")
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
        var project1: CBProject?
        var project2: CBProject?

        getProjectForXML(xmlFile: firstProjectName) { project, error  in
            XCTAssertNil(error)
            project1 = project
        }

        getProjectForXML(xmlFile: secondProjectName) { project, error in
            XCTAssertNil(error)
            project2 = project
        }

        XCTAssertNotNil(project1, "ERROR: project 1 is wrong or the XML file is not present!")
        XCTAssertNotNil(project2, "ERROR: project 2 is wrong or the XML file is not present!")
        XCTAssertTrue(project1 == project2)
    }

    func getProjectForXML(xmlFile: String, completion: @escaping (CBProject?, XMLAbstractError?) -> Void) {
        var xmlPath: String?
        getPathForXML(xmlFile: xmlFile) { path, error in
            if error != nil {
                completion(nil, error)
            }
            xmlPath = path
        }

        guard let path = xmlPath else { completion(nil, .invalidPath); return }

        let catrobatParser = CBXMLParser(path: path)
        if catrobatParser == nil {
            completion(nil, .unexpectedError)
        }

        catrobatParser?.parseProject(completion: { error in
            if error != nil {
                completion(nil, .parsingError)
            }

            let project = catrobatParser?.getProject()
            completion(project, nil)
        })
    }

    func getObjcProjectForXML(xmlFile: String, completion: @escaping (Project?, XMLAbstractError?) -> Void) {
        var xmlPath: String?
        getPathForXML(xmlFile: xmlFile) { path, error in
            if error != nil {
                completion(nil, error)
            }
            xmlPath = path
        }

        guard let path = xmlPath else { completion(nil, .invalidPath); return }

        let catrobatParser = CBXMLParser(path: path)
        if catrobatParser == nil {
            completion(nil, .unexpectedError)
        }

        catrobatParser?.parseProject(completion: { error in
            if error != nil {
                completion(nil, .parsingError)
            }

            let project = catrobatParser?.getProjectObjc()
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

    func testBackAndForthMappingOfProjectToCBProject(filename: String) -> Bool {
        var cbProject: CBProject?
        getProjectForXML(xmlFile: filename) { project, _  in
            cbProject = project
        }

        let project = CBXMLMappingToObjc.mapCBProjectToProject(project: cbProject)
        guard project != nil else { return false }

        let backMapped = CBXMLMappingFromObjc.mapProjectToCBProject(project: project!)
        guard backMapped != nil else { return false }

        return checkIfCountsAreEqual(lhs: cbProject!, rhs: backMapped!)
    }

    func checkIfCountsAreEqual(lhs: CBProject, rhs: CBProject) -> Bool {
        guard lhs.header == rhs.header else { return false }
        guard let lhsObjectList = lhs.scenes?.first?.objectList?.objects else { return false }
        guard let rhsObjectList = rhs.scenes?.first?.objectList?.objects else { return false }
        guard lhsObjectList.count == rhsObjectList.count else { return false }

        for (index, object) in lhsObjectList.enumerated() {

            if object.reference?.isEmpty == false || rhsObjectList[index].reference?.isEmpty == false {
                continue
            }

            guard object.name == rhsObjectList[index].name else { return false }

            if object.lookList?.looks?.count != rhsObjectList[index].lookList?.looks?.count {
                guard object.lookList?.looks.isEmptyButNotNil() == rhsObjectList[index].lookList?.looks.isEmptyButNotNil() else { return false }
            } else {
                guard object.lookList?.looks?.count == rhsObjectList[index].lookList?.looks?.count else { return false }
            }

            if object.soundList?.sounds?.count != rhsObjectList[index].soundList?.sounds?.count {
                guard object.soundList?.sounds.isEmptyButNotNil() == rhsObjectList[index].soundList?.sounds.isEmptyButNotNil() else { return false }
            } else {
                guard object.soundList?.sounds.isEmptyButNotNil() == rhsObjectList[index].soundList?.sounds.isEmptyButNotNil() else { return false }
            }

            guard object.scriptList?.scripts?.count == rhsObjectList[index].scriptList?.scripts?.count else { return false }
        }

        return true
    }
}

enum XMLAbstractError: Error {
    case invalidPath
    case parsingError
    case unexpectedError
}
