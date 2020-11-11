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

//    func testDVRGeneration() {
//        let group = DispatchGroup()
//        group.enter()
//
//        let dvrSession = Session(cassetteName: "newCassete")
//        let brick = WebRequestBrick(session: dvrSession)
//
//        brick.sendRequest(request: "https://official-joke-api.appspot.com/random_joke") { _, _ in
//            group.leave()
//        }
//
//        group.wait()
//    }

    func testWebRequestSucceeds() {
        let dvrSession = Session(cassetteName: "WebRequestBrick.fetchJoke.success")
        let brick = WebRequestBrick(session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch Random Joke")

        brick.sendRequest(request: "https://official-joke-api.appspot.com/random_joke") { response, error in
            XCTAssertNil(error)
            XCTAssertNotNil(response)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testWebRequestFailsWithRequestError() {
        let dvrSession = Session(cassetteName: "WebRequestBrick.fetchJoke.fail.request")
        let brick = WebRequestBrick(session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch Random Joke")

        brick.sendRequest(request: "https://official-joke-api.appspot.com/random_jokeX") { response, error in
            XCTAssertNotEqual(response, "")

            guard let error = error else { XCTFail("no error received"); return }
            switch error {
            case let .request(error: _, statusCode: statusCode):
                XCTAssertNotEqual(statusCode, 200)
            default:
                XCTFail("wrong error received")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testWebRequestFailsWithTimeoutError() {
        let url = URL(string: "https://official-joke-api.appspot.com/random_joke")!
        let response = HTTPURLResponse(url: url, statusCode: NSURLErrorTimedOut, httpVersion: nil, headerFields: nil)
        let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut, userInfo: nil)
        let session = URLSessionMock(response: response, error: error)
        let brick = WebRequestBrick(session: session)
        let expectation = XCTestExpectation(description: "Fetch Random Joke")

        brick.sendRequest(request: url.absoluteString) { _, error in
            guard let error = error else { XCTFail("no error received"); return }
            switch error {
            case .timeout:
                expectation.fulfill()
            default:
                XCTFail("wrong error received")
            }
        }

         wait(for: [expectation], timeout: 1.0)
    }

    func testWebRequestFailsWithUnexpectedError() {
        let dvrSession = URLSessionMock()
        let brick = WebRequestBrick(session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch Random Joke")

        brick.sendRequest(request: "https://official-joke-api.appspot.com/random_joke") { _, error in
            guard let error = error else { XCTFail("no error received"); return }
            switch error {
            case .unexpectedError:
                expectation.fulfill()
            default:
                XCTFail("wrong error received")
            }
        }

        wait(for: [expectation], timeout: 1.0)
    }
}
