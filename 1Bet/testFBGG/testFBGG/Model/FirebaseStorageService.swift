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
    
    /// Singleton instance of `FirebaseStorageService` for shared access across the app.
    static let shared = FirebaseStorageService()
    
    /// Reference to the Firebase Storage.
    let storage = Storage.storage()
    
    /// Reference to the Firestore database.
    private let firestore = Firestore.firestore()
    
    // MARK: - Functions
    
    /// Downloads the latest photo from Firebase Storage, based on a path stored in Firestore.
    ///
    /// - Parameter completion: A completion handler returning the downloaded `UIImage` if successful, or `nil` on failure.
    func downloadLatestPhoto(completion: @escaping (UIImage?) -> Void) {
        let db = Firestore.firestore()
        let latestImageRef = db.collection("photos").document("latestImage")
        
        // Fetch the path of the latest image from Firestore
        latestImageRef.getDocument { (document, error) in
            if let document = document, document.exists, let data = document.data(), let path = data["path"] as? String {
                let storageRef = Storage.storage().reference(withPath: path)
                
                // Download the image data from Firebase Storage
                storageRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
                    if let error = error {
                        print("Error downloading the image: \(error)")
                        completion(nil)
                        return
                    }
                    
                    // Convert the downloaded data to a UIImage
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

    /// Uploads an image to Firebase Storage and updates the image reference in Firestore.
    ///
    /// - Parameter image: The `UIImage` to be uploaded.
    func uploadPhoto(image: UIImage) {
        // Create a unique storage path for the image
        let storageRef = Storage.storage().reference().child("photos/\(UUID().uuidString).jpg")
        
        // Convert the image to JPEG data with 80% compression quality
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            // Upload the image data to Firebase Storage
            storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                if let error = error {
                    print("Error uploading the image: \(error)")
                    return
                }
                
                // Update the Firestore reference with the new image path
                let db = Firestore.firestore()
                db.collection("photos").document("latestImage").setData(["path": storageRef.fullPath]) { error in
                    if let error = error {
                        print("Error updating Firestore: \(error)")
                    } else {
                        print("Image reference successfully updated in Firestore.")
                    }
                }
            }
        }
    }
}

/// Enumeration for possible Firebase Storage errors.
enum FirebaseStorageError: Error {
    case invalidImageData      // When image data is invalid or nil
    case downloadURLNotFound    // When the download URL is not found
    case noDocumentsFound       // When no documents are found in Firestore for a query
}
