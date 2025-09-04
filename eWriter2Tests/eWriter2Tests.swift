//
//  eWriter2Tests.swift
//  eWriter2Tests
//
//  Created by Nikolay Nikiforov on 03.10.2024.
//

import XCTest
@testable import eWriter2

final class eWriter2Tests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRecalculateCursorPositionAcrossNewlines() throws {
        let text = "line1\nline2\nline3"
        XCTAssertEqual(recalculateCursorPosition(text: text, position: 5), 6)
        XCTAssertEqual(recalculateCursorPosition(text: text, position: 10), 12)
    }

    func testGetCursorParagraphInfoAtDocumentStart() throws {
        let text = "line1\nline2"
        let info = getCursorParagraphInfo(text: text, cursorPosition: 0, selectionStart: nil, selectionEnd: nil)
        XCTAssertNotNil(info)
        XCTAssertEqual(info?.paragraphIndex, 0)
        XCTAssertEqual(info?.positionInParagraph, 0)
    }

}
