//
//  FirebaseStoragePicture.swift
//  testFBGG
//
//  Created by Florian Peyrony on 12/05/2024.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore
import UIKit

class FirebaseStorageService {
    
    static let shared = FirebaseStorageService()
    let storage = Storage.storage()
    private let firestore = Firestore.firestore()
    
    // Fonction pour télécharger une photo depuis Firebase Storage
    func downloadLatestPhoto(completion: @escaping (UIImage?) -> Void) {
        let db = Firestore.firestore()
        let latestImageRef = db.collection("photos").document("latestImage")
        
        latestImageRef.getDocument { (document, error) in
            if let document = document, document.exists, let data = document.data(), let path = data["path"] as? String {
                let storageRef = Storage.storage().reference(withPath: path)
                storageRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
                    if let error = error {
                        print("Erreur lors du téléchargement de l'image: \(error)")
                        completion(nil)
                        return
                    }
                    
                    if let data = data, let image = UIImage(data: data) {
                        completion(image)
                    } else {
                        completion(nil)
                    }
                }
            } else {
                print("Document does not exist")
                completion(nil)
            }
        }
    }

    
    // Fonction pour envoyer une photo vers Firebase Storage
    func uploadPhoto(image: UIImage) {
        let storageRef = Storage.storage().reference().child("photos/\(UUID().uuidString).jpg")
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                if let error = error {
                    print("Erreur lors de l'upload de l'image: \(error)")
                    return
                }
                // Mise à jour de la référence dans Firestore
                let db = Firestore.firestore()
                db.collection("photos").document("latestImage").setData(["path": storageRef.fullPath]) { error in
                    if let error = error {
                        print("Erreur lors de la mise à jour de Firestore: \(error)")
                    } else {
                        print("Référence mise à jour avec succès.")
                    }
                }
            }
        }
    }
}

enum FirebaseStorageError: Error {
    case invalidImageData
    case downloadURLNotFound
    case noDocumentsFound
}
