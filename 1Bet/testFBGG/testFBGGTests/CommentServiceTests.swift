//
//  testFBGGTests.swift
//  testFBGGTests
//
//  Created by Florian Peyrony on 29/04/2023.
//
import XCTest
@testable import testFBGG

class CommentServiceTests: XCTestCase {

    var commentService: CommentService!

    override func setUp() {
        super.setUp()
        commentService = CommentService()
    }

    override func tearDown() {
        commentService = nil
        super.tearDown()
    }

    func testGetComments() {
        let mockData: [[String: Any]] = [
            ["nameOfWriter": "John Doe", "likes": 0, "comment": "This is a test comment 1", "publicationID": 1],
            ["nameOfWriter": "Jane Smith", "likes": 2, "comment": "This is a test comment 2", "publicationID": 1],
            ["nameOfWriter": "Bob Johnson", "likes": 5, "comment": "This is a test comment 3", "publicationID": 1],
            ["nameOfWriter": "Tom Williams", "likes": 1, "comment": "This is a test comment 4", "publicationID": 1]
        ]
        
        //commentService.database. = mockData

        commentService.getComments(forPublicationID: 1) { mockData in
            XCTAssertEqual(mockData.count, 4, "There should be 4 comments for publicationID 1")
            XCTAssertEqual(mockData[0].nameOfWriter, "John Doe", "The first comment should be written by John Doe")
            XCTAssertEqual(mockData[1].nameOfWriter, "Jane Smith", "The second comment should be written by Jane Smith")
            XCTAssertEqual(mockData[2].nameOfWriter, "Bob Johnson", "The third comment should be written by Bob Johnson")
            XCTAssertEqual(mockData[3].nameOfWriter, "Tom Williams", "The fourth comment should be written by Tom Williams")
        }
    }
}
