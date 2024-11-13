//
//  CommentService.swift
//  testFBGG
//
//  Created by Florian Peyrony on 17/01/2023.
//

import Foundation
import Firebase
import FirebaseFirestore

class CommentService {
    
    // MARK: - Properties
    
    /// Singleton instance of `CommentService` to access shared methods and properties.
    static let shared = CommentService()
    
    /// Reference to the Firestore database.
    private let database = Firestore.firestore()
    
    // MARK: - Functions

    /// Publishes a new comment directly to the `comments` field in a publication document.
    ///
    /// - Parameters:
    ///   - uid: The unique identifier of the user posting the comment.
    ///   - commentText: The text content of the comment.
    ///   - nameOfWriter: The name of the user writing the comment.
    ///   - publicationID: The ID of the publication the comment is associated with.
    func publishComment(uid: String?, commentText: String, nameOfWriter: String, publicationID: String) {
        guard let uid = uid else { return }
        
        // Creating the comment data without the timestamp
        let commentData: [String: Any] = [
            "uid": uid,
            "nameOfWriter": nameOfWriter,
            "commentText": commentText
        ]
        
        let publicationRef = database.collection("publication").document(publicationID)
        
        // Adding the new comment to the comments field as an array union
        publicationRef.updateData([
            "comments": FieldValue.arrayUnion([commentData])
        ]) { error in
            if let error = error {
                print("Error adding comment to publication: \(error)")
            } else {
                print("Comment successfully added to publication ID: \(publicationID)")
            }
        }
    }
    
    /// Retrieves comments from Firestore stored in the `comments` field of a publication.
    ///
    /// - Parameters:
    ///   - publicationID: The ID of the publication to fetch comments for.
    ///   - completion: A closure called with an array of dictionaries representing comments.
    func getCommentsFromPublication(forPublicationID publicationID: String, completion: @escaping ([[String: Any]]) -> Void) {
        let publicationRef = database.collection("publication").document(publicationID)
        
        publicationRef.getDocument { document, error in
            if let error = error {
                print("Error retrieving comments: \(error)")
                completion([])
                return
            }
            
            if let document = document, document.exists,
               let data = document.data(),
               let comments = data["comments"] as? [[String: Any]] {
                completion(comments)
            } else {
                print("No comments found for publicationID: \(publicationID)")
                completion([])
            }
        }
    }
}
