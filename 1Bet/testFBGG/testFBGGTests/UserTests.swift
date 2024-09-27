//
//  UserTests.swift
//  testFBGGTests
//
//  Created by Florian Peyrony on 23/09/2024.
//

import XCTest
@testable import testFBGG

class UserTests: XCTestCase {

    func testUserInitializationWithValidData() {
        let validData: [String: Any] = [
            "isAdmin": true,
            "mail": "florian@example.com",
            "name": "Florian Peyrony"
        ]

        let user = User(data: validData)

        XCTAssertEqual(user.isAdmin, true, "Expected isAdmin to be true")
        XCTAssertEqual(user.mail, "florian@example.com", "Expected email to be florian@example.com")
        XCTAssertEqual(user.name, "Florian Peyrony", "Expected name to be Florian Peyrony")
    }

    func testUserInitializationWithMissingData() {
        let incompleteData: [String: Any] = [:]

        let user = User(data: incompleteData)

        XCTAssertEqual(user.isAdmin, false, "Expected isAdmin to default to false")
        XCTAssertEqual(user.mail, "", "Expected email to default to an empty string")
        XCTAssertEqual(user.name, "", "Expected name to default to an empty string")
    }
    
    func testUserInitializationWithInvalidData() {
        let invalidData: [String: Any] = [
            "isAdmin": "not a bool",
            "mail": 12345,
            "name": NSNull()
        ]

        let user = User(data: invalidData)

        XCTAssertEqual(user.isAdmin, false, "Expected isAdmin to default to false with invalid data")
        XCTAssertEqual(user.mail, "", "Expected mail to default to empty string with invalid data")
        XCTAssertEqual(user.name, "", "Expected name to default to empty string with invalid data")
    }
}
