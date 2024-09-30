//
//  MockFirebaseStorageService.swift
//  testFBGG
//
//  Created by Florian Peyrony on 30/09/2024.
//

import UIKit
@testable import testFBGG


class MockFirebaseStorageService: FirebaseStorageService {
    override func downloadLatestPhoto(completion: @escaping (UIImage?) -> Void) {
        // Simule un document manquant en appelant directement le completion avec nil
        completion(nil)
    }
}
