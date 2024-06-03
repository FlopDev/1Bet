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
    
    // MARK: - Preperties
    
    static let shared = CommentService()
    var database = Firestore.firestore()
    var userInfo: User?
    let vc = MainPageViewController()
    
    var comments: [[String: Any]] = []
    
    
    // MARK: - Functions
    func publishAComment(uid: String?, comment:String, nameOfWriter: String, publicationID: String) {
        let docRef = database.document("comments/\(String(describing: uid))")
        docRef.setData(["nameOfWriter": nameOfWriter, "likes": 0, "comment": comment, "publicationID": publicationID])
        print("Le commentaire enregistré porte le publicationID : \(publicationID)")
    }
    func getComments(forPublicationID publicationID: String, completion: @escaping ([Comment]) -> Void) {
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
}
