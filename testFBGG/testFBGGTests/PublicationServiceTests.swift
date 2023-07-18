//
//  PublicationServiceTests.swift
//  testFBGGTests
//
//  Created by Florian Peyrony on 02/05/2023.
//

import XCTest
@testable import testFBGG

class PublicationServiceTests: XCTestCase {

    var publicationService: PublicationService!

    override func setUp() {
        super.setUp()
        publicationService = PublicationService()
    }

    override func tearDown() {
        publicationService = nil
        super.tearDown()
    }

    func testSavePublicationOnDB() {
        let publicationID = 1
        let mockData: [String: Any] = [
            "date": "2022-05-02",
            "description": "This is a test publication",
            "percentOfBankroll": "10%",
            "publicationID": publicationID,
            "trustOnTen": "7/10"
        ]
       // publicationService.database. = mockData

        publicationService.savePublicationOnDB(date: "2022-05-02", description: "This is a test publication", percentOfBankroll: "10%", publicationID: publicationID, trustOnTen: "7/10")

        // Verify that the publication was added to the mock database
        //let document = mockFirestore.mockData["publications/\(publicationID)"] as? [String: Any]
        //XCTAssertNotNil(document, "Document should not be nil")
        //XCTAssertEqual(document!["date"] as! String, "2022-05-02", "The publication date should be 2022-05-02")
        //XCTAssertEqual(document!["description"] as! String, "This is a test publication", "The publication description should be 'This is a test publication'")
        //XCTAssertEqual(document!["percentOfBankroll"] as! String, "10%", "The publication percentOfBankroll should be '10%'")
        //XCTAssertEqual(document!["trustOnTen"] as! String, "7/10", "The publication trustOnTen should be '7/10'")
    }
}
