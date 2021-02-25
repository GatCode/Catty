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

import DVR
import XCTest

@testable import Pocket_Code

final class WebRequestBrickTests: XCTestCase {

    var project: Project!
    var spriteObject: SpriteObject!
    var spriteNode: CBSpriteNode!
    var script: Script!
    var scheduler: CBScheduler!
    var context: CBScriptContextProtocol!
    var userList: UserList!
    var brick: WebRequestBrick!
    var broadcastHandler: CBBroadcastHandler!

    override func setUp() {
        project = Project()
        let scene = Scene(name: "testScene")
        spriteObject = SpriteObject()
        spriteObject.scene = scene
        spriteObject.name = "SpriteObjectName"

        spriteNode = CBSpriteNode(spriteObject: spriteObject)
        spriteObject.spriteNode = spriteNode
        spriteObject.scene.project = project
        project.scene = spriteObject.scene

        script = Script()
        script.object = spriteObject

        spriteObject.scene.project!.userData = UserDataContainer()

        userList = UserList(name: "testName")
        spriteObject.userData.add(userList)

        brick = WebRequestBrick()
        brick.userVariable = UserVariable(name: "var")
        brick.request = Formula(string: "http://catrob.at/joke")
        brick.script = script

        let logger = CBLogger(name: "Logger")
        broadcastHandler = CBBroadcastHandler(logger: logger)
        let formulaInterpreter = FormulaManager(stageSize: Util.screenSize(true), landscapeMode: false)
        scheduler = CBScheduler(logger: logger, broadcastHandler: broadcastHandler, formulaInterpreter: formulaInterpreter, audioEngine: AudioEngineMock())
        context = CBScriptContext(script: script, spriteNode: spriteNode, formulaInterpreter: formulaInterpreter, touchManager: formulaInterpreter.touchManager)
    }
    
    func testWebRequestSucceeds() {
        let brick = WebRequestBrick()
        let url = "https://official-joke-api.appspot.com/random_joke"
        brick.createDownloader(url: url, session: nil)
        
        let config = brick.downloader?.session?.configuration
        let delegate = brick.downloader?.session?.delegate
        let backingSession = URLSession(configuration: config!, delegate: delegate, delegateQueue: nil)

        let dvrSession = Session(cassetteName: "WebRequestBrick.fetchJoke.success", backingSession: backingSession)
        brick.downloader?.session = dvrSession
        
        let expectation = XCTestExpectation(description: "Fetch Random Joke Succeeds")

        brick.sendRequest() { response, error in
            XCTAssertNil(error)
            XCTAssertNotNil(response)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

//    func testWebRequestFailsWithRequestError() {
//        let brick = WebRequestBrick()
//        let url = "https://official-joke-api.appspot.com/random_jokeX"
//        brick.createDownloader(url: url, session: nil)
//
//        let config = brick.downloader?.session?.configuration
//        let delegate = brick.downloader?.session?.delegate
//        let backingSession = URLSession(configuration: config!, delegate: delegate, delegateQueue: nil)
//
//        let dvrSession = Session(cassetteName: "WebRequestBrick.fetchJoke.fail.request", backingSession: backingSession)
//        brick.downloader?.session = dvrSession
//
//        let expectation = XCTestExpectation(description: "Fetch Random Joke Request Error")
//
//        brick.sendRequest() { response, error in
//            guard let error = error else { XCTFail("no error received"); return }
//            switch error {
//            case let .request(error: _, statusCode: statusCode):
//                XCTAssertNotEqual(statusCode, 200)
//            default:
//                XCTFail("wrong error received")
//            }
//            expectation.fulfill()
//        }
//
//        wait(for: [expectation], timeout: 1.0)
//    }
//
//    func testWebRequestFailsWithTimeoutError() {
//        let url = "https://official-joke-api.appspot.com/random_joke"
//        let response = HTTPURLResponse(url: URL(string: url)!, statusCode: NSURLErrorTimedOut, httpVersion: nil, headerFields: nil)
//        let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut, userInfo: nil)
//        let session = URLSessionMock(response: response, error: error)
//
//        let brick = WebRequestBrick()
//        brick.createDownloader(url: url, session: session)
//
//        let expectation = XCTestExpectation(description: "Fetch Random Joke")
//
//        brick.sendRequest() { _, error in
//            guard let error = error else { XCTFail("no error received"); return }
//            switch error {
//            case .timeout:
//                expectation.fulfill()
//            default:
//                XCTFail("wrong error received")
//            }
//        }
//
//         wait(for: [expectation], timeout: 1.0)
//    }
//
//    func testWebRequestFailsWithUnexpectedError() {
//        let brick = WebRequestBrick()
//        let url = "https://official-joke-api.appspot.com/random_joke"
//        brick.createDownloader(url: url, session: nil)
//
//        let dvrSession = URLSessionMock()
//        brick.downloader?.session = dvrSession
//
//        let expectation = XCTestExpectation(description: "Fetch Random Joke Unexpected Error")
//
//        brick.sendRequest() { _, error in
//            guard let error = error else { XCTFail("no error received"); return }
//            switch error {
//            case .unexpectedError:
//                expectation.fulfill()
//            default:
//                XCTFail("wrong error received")
//            }
//        }
//
//        wait(for: [expectation], timeout: 1.0)
//    }

    func testWebRequestNormal() {
        let variableBefore = brick.userVariable?.value as? String

        switch brick.instruction() {
        case let .waitExecClosure(closure):
            closure(context, scheduler)
            brick.callbackSubmit(with: "request", error: nil, scheduler: scheduler)
        default:
            XCTFail("Fatal Error")
        }
        let variableAfter = brick.userVariable?.value as? String

        XCTAssertNotEqual(variableBefore, variableAfter)
    }

    func testWebRequestNoChange() {
        brick.userVariable?.value = ""
        let variableBefore = brick.userVariable?.value as? String

        switch brick.instruction() {
        case let .waitExecClosure(closure):
            closure(context, scheduler)
            brick.callbackSubmit(with: "", error: nil, scheduler: scheduler)
        default:
            XCTFail("Fatal Error")
        }
        let variableAfter = brick.userVariable?.value as? String

        XCTAssertEqual(variableBefore, variableAfter)
    }

    func testWebRequestNoUserVariable() {
        brick.userVariable = nil

        switch brick.instruction() {
        case let .waitExecClosure(closure):
            closure(context, scheduler)
            brick.callbackSubmit(with: "request", error: nil, scheduler: scheduler)
        default:
            XCTFail("Fatal Error")
        }

         XCTAssertEqual(brick.userVariable, nil)
    }
}
