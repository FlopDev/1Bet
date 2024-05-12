//
//  FirebaseStoragePicture.swift
//  testFBGG
//
//  Created by Florian Peyrony on 12/05/2024.
//

import Foundation
import FirebaseStorage
import UIKit

class FirebaseStorageService {

    static let shared = FirebaseStorageService()
    let storage = Storage.storage()

    // Fonction pour ajouter une photo à Firebase Storage
    func uploadPhoto(image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion(.failure(FirebaseStorageError.invalidImageData))
            return
        }

        let storageRef = storage.reference()
        let photoRef = storageRef.child("photos/\(UUID().uuidString).jpg")

        let uploadTask = photoRef.putData(imageData, metadata: nil) { (metadata, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                photoRef.downloadURL { (url, error) in
                    if let downloadURL = url {
                        completion(.success(downloadURL))
                    } else {
                        completion(.failure(FirebaseStorageError.downloadURLNotFound))
                    }
                }
            }
        }
    }

    // Fonction pour récupérer une photo à partir de son URL
    func downloadPhoto(from url: URL, completion: @escaping (Result<UIImage?, Error>) -> Void) {
        let downloadTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data, let image = UIImage(data: data) else {
                completion(.success(nil))
                return
            }
            completion(.success(image))
        }
        downloadTask.resume()
    }
}

// Définition des erreurs possibles
enum FirebaseStorageError: Error {
    case invalidImageData
    case downloadURLNotFound
}
