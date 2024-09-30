//
//  CommentTests.swift
//  testFBGGTests
//
//  Created by Florian Peyrony on 23/09/2024.
//

import XCTest
@testable import testFBGG

class CommentTests: XCTestCase {

    func testCommentInitializationWithValidData() {
        let validData: [String: Any] = [
            "likes": 10,
            "nameOfWriter": "Florian",
            "publicationID": 123,
            "comment": "This is a comment",
            "isLiked": true
        ]

        let comment = Comment(data: validData)

        XCTAssertEqual(comment.likes, 10, "Expected likes to be 10")
        XCTAssertEqual(comment.nameOfWriter, "Florian", "Expected nameOfWriter to be Florian")
        XCTAssertEqual(comment.publicationID, 123, "Expected publicationID to be 123")
        XCTAssertEqual(comment.commentText, "This is a comment", "Expected commentText to be 'This is a comment'")
        XCTAssertEqual(comment.isLiked, true, "Expected isLiked to be false by default")
    }

    func testCommentInitializationWithMissingData() {
        let incompleteData: [String: Any] = [:]

        let comment = Comment(data: incompleteData)

        XCTAssertEqual(comment.likes, 0, "Expected likes to default to 0")
        XCTAssertEqual(comment.nameOfWriter, "", "Expected nameOfWriter to default to an empty string")
        XCTAssertEqual(comment.publicationID, 0, "Expected publicationID to default to 0")
        XCTAssertEqual(comment.commentText, "", "Expected commentText to default to an empty string")
        XCTAssertEqual(comment.isLiked, false, "Expected isLiked to default to false")
    }

    func testCommentInitializationWithInvalidData() {
        let invalidData: [String: Any] = [
            "likes": "invalid",
            "nameOfWriter": NSNull(),
            "publicationID": "not a number",
            "comment": 12345,
            "isLiked": "invalid"
        ]

        let comment = Comment(data: invalidData)

        XCTAssertEqual(comment.likes, 0, "Expected likes to default to 0 with invalid data")
        XCTAssertEqual(comment.nameOfWriter, "", "Expected nameOfWriter to default to empty string with invalid data")
        XCTAssertEqual(comment.publicationID, 0, "Expected publicationID to default to 0 with invalid data")
        XCTAssertEqual(comment.commentText, "", "Expected commentText to default to empty string with invalid data")
        XCTAssertEqual(comment.isLiked, false, "Expected isLiked to be false by default")
    }
}
