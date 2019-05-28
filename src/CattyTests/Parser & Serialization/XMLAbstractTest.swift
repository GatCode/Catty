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

    func writeXMLFileFor(projectName: String) {

        // --------------------------------------------------
        // TODO: change getProjectForXML2 to getProjectForXML
        // --------------------------------------------------

        var project: CBProject?
        getProjectForXML2(xmlFile: projectName) { proj in
            project = proj
        }

        guard let filledProject = project else { return }
        let xml = CBXMLSerializer2.shared.createXMLDocument(project: filledProject)

        CBXMLSerializer2.shared.writeXMLFile(filename: "file.txt", data: xml)

        print(xml)
    }

    func compareProject(firstProjectName: String, withProject secondProjectName: String) {

        // --------------------------------------------------
        // TODO: change getProjectForXML2 to getProjectForXML
        // --------------------------------------------------

        var project1: CBProject?
        var project2: CBProject?

        getProjectForXML2(xmlFile: firstProjectName) { project in
            project1 = project
        }

        getProjectForXML2(xmlFile: secondProjectName) { project in
            project2 = project
        }

        XCTAssertNotNil(project1, "ERROR: \(firstProjectName) is wrong or the XML file is not present!")
        XCTAssertNotNil(project2, "ERROR: \(firstProjectName) is wrong or the XML file is not present!")
        XCTAssertTrue(project1! == project2!)
    }

    func isXMLElement(xmlElement: GDataXMLElement, equalToXMLElementForXPath xPath: String, inProjectForXML project: String) -> Bool {
        let document = self.getXMLDocumentForPath(xmlPath: self.getPathForXML(xmlFile: project))
        let array = self.getXMLElementsForXPath(document, xPath: xPath)
        XCTAssertEqual(array!.count, 1)
        let xmlElementFromFile = array!.first
        return xmlElement.isEqual(to: xmlElementFromFile)
    }

    func getXMLElementsForXPath(_ document: GDataXMLDocument, xPath: String) -> [GDataXMLElement]? {
        do {
            let rootElement = document.rootElement()
            let elementArray = try rootElement!.nodes(forXPath: xPath)
            return (elementArray as! [GDataXMLElement])
        } catch let error as NSError {
            XCTFail("Could not retrieve XML Element: " + error.domain)
        }
        return nil
    }

    func isProject(firstProject: Project, equalToXML secondProject: String) -> Bool {
        guard let firstDocument = CBXMLSerializer.xmlDocument(for: firstProject) else {
            XCTFail("Could not serialize xml document for project ")
            return false
        }
        let secondDocument = self.getXMLDocumentForPath(xmlPath: self.getPathForXML(xmlFile: secondProject))
        guard let firstRoot = firstDocument.rootElement(), let secondRoot = secondDocument.rootElement() else {
            return false
        }
        return firstRoot.isEqual(to: secondRoot)
    }

    func getXMLDocumentForPath(xmlPath: String) -> GDataXMLDocument {
        let xmlFile: String
        var document = GDataXMLDocument()
        do {
            try xmlFile = String(contentsOfFile: xmlPath, encoding: String.Encoding.utf8)
            let xmlData = xmlFile.data(using: String.Encoding.utf8)
            if xmlData == nil {
                XCTFail("Could not retrieve XML Document for path \(xmlPath)")
            }
            try document = GDataXMLDocument(data: xmlData!, options: 0)
        } catch let error as NSError {
            print("Error: \(error.domain)")
            XCTFail("Could not retrieve XML Document for path \(xmlPath)")
        }
        return document
    }

    func saveProject(project: Project) {
        guard let fileManager = CBFileManager.shared() else {
            XCTFail("Could not retrieve file manager")
            return
        }
        let xmlPath = String.init(format: "%@%@", project.projectPath(), kProjectCodeFileName)
        let serializer = CBXMLSerializer(path: xmlPath, fileManager: fileManager)
        serializer?.serializeProject(project)
    }

    func testParseXMLAndSerializeProjectAndCompareXML(xmlFile: String) {
        let project = self.getProjectForXML(xmlFile: xmlFile)
        let equal = self.isProject(firstProject: project, equalToXML: xmlFile)
        XCTAssertTrue(equal, "Serialized project and XML are not equal (\(xmlFile))")
    }

    func getProjectForXML(xmlFile: String) -> Project {
        let xmlPath = getPathForXML(xmlFile: xmlFile)
        let languageVersion = Util.detectCBLanguageVersionFromXML(withPath: xmlPath)
        // detect right parser for correct catrobat language version

        let catrobatParser = CBXMLParser.init(path: xmlPath)
        if catrobatParser == nil {
            XCTFail("Could not retrieve parser for xml file \(xmlFile)")
        }

        if !catrobatParser!.isSupportedLanguageVersion(languageVersion) {
            let parser = Parser()
            let project = parser.generateObjectForProject(withPath: xmlPath)
            if project == nil {
                XCTFail("Could not parse project from file \(xmlFile)")
            }
            return project!
        } else {
            let project = catrobatParser!.parseAndCreateProject()
            if project == nil {
                XCTFail("Could not parse project from file \(xmlFile)")
            }
            return project!
        }
    }

    func getProjectForXML2(xmlFile: String, completion: @escaping (CBProject?) -> Void) {

        // -----------------------------------------
        // TODO: change CBXMLParser2 to CBXMLParser
        // -----------------------------------------

        let xmlPath = getPathForXML(xmlFile: xmlFile)

        let catrobatParser2 = CBXMLParser2(path: xmlPath)
        if catrobatParser2 == nil {
            XCTFail("Could not retrieve parser for xml file \(xmlFile)")
        }

        catrobatParser2?.parseProject(completion: { parseSuccess in
            if parseSuccess {
                let project = catrobatParser2?.getProject()
                if project == nil {
                    XCTFail("Could not parse project from file \(xmlFile)")
                }
                completion(project)
            }
        })
    }

    func getPathForXML(xmlFile: String) -> String {
        let bundle = Bundle.init(for: self.classForCoder)
        guard let path = bundle.path(forResource: xmlFile, ofType: "xml") else {
            XCTFail("Could not retrieve path for XML File \(xmlFile)")
            return "path_not_found"
        }
        return path
    }
}
