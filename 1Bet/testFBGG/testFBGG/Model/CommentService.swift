//
//  CommentService.swift
//  testFBGG
//
//  Created by Florian Peyrony on 17/01/2023.
//

import Foundation
import Firebase
import FirebaseFirestore
import FacebookLogin
import GoogleSignIn

class CommentService {
    
    // MARK: - Properties
    
    /// Singleton instance of `CommentService` to access shared methods and properties.
    static let shared = CommentService()
    
    /// Reference to the Firestore database.
    var database = Firestore.firestore()
    
    /// Holds user information for the current session.
    var userInfo: User?
    
    /// Reference to the main page view controller (if needed).
    let vc = MainPageViewController()
    
    /// Local storage for comments, used for business logic testing or local caching.
    var comments: [Comment] = []
    
    // MARK: - Functions

    /// Adds a new comment to the local `comments` array for local-only storage or testing purposes.
    ///
    /// - Parameter data: A dictionary containing the data needed to initialize a `Comment`.
    func addComment(data: [String: Any]) {
        let newComment = Comment(data: data)
        comments.append(newComment)
    }
    
    /// Retrieves comments from the local `comments` array that match a given publication ID.
    ///
    /// - Parameter publicationID: The ID of the publication to filter comments for.
    /// - Returns: An array of `Comment` objects that belong to the specified publication.
    func getComments(forPublicationID publicationID: String) -> [Comment] {
        return comments.filter { "\($0.publicationID)" == publicationID }
    }

    /// Retrieves comments from Firestore that are associated with a specified publication ID.
    ///
    /// - Parameters:
    ///   - publicationID: The ID of the publication to fetch comments for.
    ///   - completion: A closure called with an array of `Comment` objects fetched from Firestore.
    func getCommentsFromFirestore(forPublicationID publicationID: String, completion: @escaping ([Comment]) -> Void) {
        database.collection("comments").whereField("publicationID", isEqualTo: publicationID).getDocuments { querySnapshot, error in
            if let error = error {
                print("Error getting documents: \(error)")
                completion([])
                return
            }
            
            // Unwrap query results and handle cases with no documents found
            guard let documents = querySnapshot?.documents else {
                print("No documents found for publicationID: \(publicationID)")
                completion([])
                return
            }
            
            if documents.isEmpty {
                print("No comments found for publicationID: \(publicationID)")
            } else {
                print("Found \(documents.count) documents for publicationID: \(publicationID)")
            }
            
            // Map Firestore document data into `Comment` objects
            var comments: [Comment] = []
            for document in documents {
                let data = document.data()
                let comment = Comment(data: data)
                comments.append(comment)
                print("Found comment: \(comment.commentText)")
            }
            
            // Pass the array of comments back via the completion handler
            completion(comments)
        }
    }
    
    /// Publishes a new comment to Firestore under the `comments` collection.
    ///
    /// - Parameters:
    ///   - uid: The unique identifier of the user posting the comment.
    ///   - comment: The text content of the comment.
    ///   - nameOfWriter: The name of the user writing the comment.
    ///   - publicationID: The ID of the publication the comment is associated with.
    func publishAComment(uid: String?, comment: String, nameOfWriter: String, publicationID: String) {
        let docRef = database.document("comments/\(String(describing: uid))")
        docRef.setData([
            "nameOfWriter": nameOfWriter,
            "likes": 0,
            "comment": comment,
            "publicationID": publicationID
        ]) { error in
            if let error = error {
                print("Failed to publish comment: \(error)")
            } else {
                print("Comment published with publicationID: \(publicationID)")
            }
        }
    }
    
    /// Fetches the total likes count for a specific publication.
    ///
    /// - Parameters:
    ///   - publicationID: The ID of the publication.
    ///   - completion: Completion handler returning the likes count or an error if fetching fails.
    func fetchLikesCount(publicationID: String, completion: @escaping (Result<Int, Error>) -> Void) {
        let docRef = database.collection("publication").document(publicationID)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let likesCount = data?["likesCount"] as? Int ?? 0
                completion(.success(likesCount))
            } else {
                completion(.failure(error!))
            }
        }
    }
    
    /// Checks if the current user has liked a specific publication.
    ///
    /// - Parameters:
    ///   - publicationID: The ID of the publication.
    ///   - userID: The ID of the user.
    ///   - completion: Completion handler returning `true` if the user has liked the publication, `false` otherwise.
    func fetchUserLikeStatus(publicationID: String, userID: String, completion: @escaping (Bool) -> Void) {
        let docRef = database.collection("publication").document(publicationID).collection("likes").document(userID)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
}
