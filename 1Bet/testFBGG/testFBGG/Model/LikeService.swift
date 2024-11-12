//
//  LikeService.swift
//  testFBGG
//
//  Created by Florian Peyrony on 08/11/2024.
//

import FirebaseFirestore
import Firebase

import Foundation
import FirebaseFirestore

/// Service responsible for managing like-related operations for publications.
class LikeService {

    /// Shared singleton instance of `LikeService`.
    static let shared = LikeService()

    /// Firestore database reference.
    private let database = Firestore.firestore()

    /// Toggles the like status for a publication by a specific user.
    ///
    /// - Parameters:
    ///   - publicationID: The ID of the publication to like/unlike.
    ///   - userID: The ID of the user who is liking/unliking the publication.
    ///   - completion: Closure called with the result of the like toggle action.
    func toggleLike(for publicationID: String, userID: String, completion: @escaping (Bool, Error?) -> Void) {
        let publicationRef = database.collection("publication").document(publicationID)

        publicationRef.getDocument { document, error in
            if let document = document, document.exists {
                var likes = document.data()?["likes"] as? [String] ?? []

                if likes.contains(userID) {
                    // User has already liked the publication, so remove the like
                    likes.removeAll { $0 == userID }
                    publicationRef.updateData(["likes": likes]) { error in
                        completion(false, error)
                    }
                } else {
                    // User has not liked the publication, so add the like
                    likes.append(userID)
                    publicationRef.updateData(["likes": likes]) { error in
                        completion(true, error)
                    }
                }
            } else {
                print("Publication document does not exist.")
                completion(false, error)
            }
        }
    }

    /// Updates the like count for a publication and retrieves the current number of likes.
    ///
    /// - Parameters:
    ///   - publicationID: The ID of the publication for which to retrieve the like count.
    ///   - completion: Closure called with the current like count and an optional error.
    func updateLikesCount(for publicationID: String, completion: @escaping (Int, Error?) -> Void) {
        let publicationRef = database.collection("publication").document(publicationID)

        publicationRef.getDocument { document, error in
            if let document = document, document.exists {
                let likes = document.data()?["likes"] as? [String] ?? []
                let likesCount = likes.count
                completion(likesCount, nil)
            } else {
                print("Error fetching likes count: \(error?.localizedDescription ?? "Unknown error")")
                completion(0, error)
            }
        }
    }

    /// Checks if a user has liked a specific publication.
    ///
    /// - Parameters:
    ///   - publicationID: The ID of the publication to check.
    ///   - userID: The ID of the user to check for a like.
    ///   - completion: Closure called with a boolean indicating if the user has liked the publication.
    func checkIfUserLiked(publicationID: String, userID: String, completion: @escaping (Bool) -> Void) {
        let publicationRef = database.collection("publication").document(publicationID)

        publicationRef.getDocument { document, error in
            if let document = document, document.exists {
                let likes = document.data()?["likes"] as? [String] ?? []
                completion(likes.contains(userID))
            } else {
                print("Error fetching document: \(error?.localizedDescription ?? "Unknown error")")
                completion(false)
            }
        }
    }
}
