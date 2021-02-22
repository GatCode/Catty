/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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

final class WebRequestDownloaderTests: XCTestCase {
    
//    func testDVRGeneration() {
//        let group = DispatchGroup()
//        group.enter()
//
//        let dvrSession = Session(cassetteName: "WebRequestDownloader.fetchJoke.success")
//
//        let downloader = WebRequestDownloader(url: "https://official-joke-api.appspot.com/random_joke", session: dvrSession)
//
//        downloader.download() { _,_ in
//            group.leave()
//        }
//
//        group.wait()
//    }

    func testWebRequestSucceeds() {
        let dvrSession = Session(cassetteName: "WebRequestDownloader.fetchJoke.success")
        let url = "https://official-joke-api.appspot.com/random_joke"
        let downloader = WebRequestDownloader(url: url, session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch Random Joke")

        downloader.download() { response, error in
            XCTAssertNil(error)
            XCTAssertNotNil(response)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }
}
