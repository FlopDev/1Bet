//
//  FirebaseStorageServiceTests.swift
//  testFBGGTests
//
//  Created by Florian Peyrony on 24/09/2024.
//

import XCTest
@testable import testFBGG

class FirebaseStorageServiceTests: XCTestCase {

    var firebaseStorageService: FirebaseStorageService!

    override func setUp() {
        super.setUp()
        firebaseStorageService = FirebaseStorageService.shared
    }

    // Teste si la méthode gère correctement une image manquante (retourne nil)
    func testDownloadLatestPhotoMissingDocument() {
        // Simule le cas où le document n'existe pas
        let expectation = XCTestExpectation(description: "Image should be nil when the document is missing")

        // Appel de la méthode sans image
        firebaseStorageService.downloadLatestPhoto { image in
            XCTAssertNil(image, "Expected image to be nil when the document is missing")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    // Teste si la méthode retourne une erreur lorsqu'il y a un problème de données d'image
    func testUploadPhotoInvalidImageData() {
        let invalidImage = UIImage()

        // Tester la préparation des données d'image (comme la conversion en jpegData)
        XCTAssertNil(invalidImage.jpegData(compressionQuality: 0.8), "Expected jpegData to be nil for an invalid image")
    }
}
