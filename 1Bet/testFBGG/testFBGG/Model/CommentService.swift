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
    //private init() { }
    var database = Firestore.firestore()
    var userInfo: User?
    let vc = MainPageViewController()
    
    var comments: [[String: Any]] = []
    
    
    // MARK: - Functions
    func publishAComment(uid: String?, comment:String, nameOfWriter: String, publicationID: Int) {
        let docRef = database.document("comments/\(uid)")
        docRef.setData(["nameOfWriter": nameOfWriter, "likes": 0, "comment": comment, "publicationID": publicationID])
        //comments["nameOfWriter"] = nameOfWriter
        //comments["comment"] = comment as String
    }
    func getComments(forPublicationID publicationID: Int, completion: @escaping ([Comment]) -> Void) {
           database.collection("comments").whereField("publicationID", isEqualTo: publicationID).getDocuments { querySnapshot, error in
               if let error = error {
                   print("Error getting documents: \(error)")
                   completion([])
               } else {
                   var comments: [Comment] = []
                   for document in querySnapshot!.documents {
                       let data = document.data()
                       let comment = Comment(data: data)
                       comments.append(comment)
                   }
                   completion(comments)
               }
           }
       }
}
