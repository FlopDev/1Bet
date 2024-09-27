//
//  PublicationServiceTests.swift
//  testFBGGTests
//
//  Created by Florian Peyrony on 24/09/2024.
//

import XCTest
@testable import testFBGG

class PublicationServiceTests: XCTestCase {

    var publicationService: PublicationService!

    override func setUp() {
        super.setUp()
        publicationService = PublicationService()
    }

    func testFormatDateString() {
        // Test 1 : Date correcte "dd/MM/yyyy"
        let formattedDate = publicationService.formatDateString("25/09/2024")
        XCTAssertEqual(formattedDate, "2024-09-25", "The formatted date should be in 'yyyy-MM-dd' format.")

        // Test 2 : Date incorrecte (la méthode doit retourner la même chaîne)
        let invalidDate = publicationService.formatDateString("invalid-date")
        XCTAssertEqual(invalidDate, "invalid-date", "The method should return the original string if the format is incorrect.")

        // Test 3 : Autre format valide mais non reconnu
        let anotherFormatDate = publicationService.formatDateString("2024/09/25")
        XCTAssertEqual(anotherFormatDate, "2024/09/25", "The method should return the original string if the format doesn't match 'dd/MM/yyyy'.")
    }
}
