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
    
    static let shared = CommentService()
    var database = Firestore.firestore()
    var userInfo: User?
    let vc = MainPageViewController()
    
    // Stocker les commentaires localement (pour tester la logique métier)
    var comments: [Comment] = []
    
    // MARK: - Functions

    // Ajouter un commentaire localement (logique métier)
    func addComment(data: [String: Any]) {
        let newComment = Comment(data: data)
        comments.append(newComment)
    }
    
    // Récupérer les commentaires associés à un publicationID
    func getComments(forPublicationID publicationID: String) -> [Comment] {
            return comments.filter { "\($0.publicationID)" == publicationID }
        }

    // Récupération des commentaires depuis Firestore (logique Firestore)
    func getCommentsFromFirestore(forPublicationID publicationID: String, completion: @escaping ([Comment]) -> Void) {
        database.collection("comments").whereField("publicationID", isEqualTo: publicationID).getDocuments { querySnapshot, error in
            if let error = error {
                print("Error getting documents: \(error)")
                completion([])
                return
            }
            
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
            
            var comments: [Comment] = []
            for document in documents {
                let data = document.data()
                let comment = Comment(data: data)
                comments.append(comment)
                print("Found comment: \(comment.commentText)")
            }
            
            completion(comments)
        }
    }
    
    func publishAComment(uid: String?, comment: String, nameOfWriter: String, publicationID: String) {
        let docRef = database.document("comments/\(String(describing: uid))")
        docRef.setData(["nameOfWriter": nameOfWriter, "likes": 0, "comment": comment, "publicationID": publicationID])
        print("Le commentaire enregistré porte le publicationID : \(publicationID)")
    }
}
