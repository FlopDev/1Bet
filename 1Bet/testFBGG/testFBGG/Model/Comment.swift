//
//  Comment.swift
//  testFBGG
//
//  Created by Florian Peyrony on 10/03/2023.
//

import Foundation

struct Comment {
    let likes: Int
    let nameOfWriter: String
    let publicationID: Int
    let commentText: String
    let isLiked: Bool?
    
    init(data: [String: Any]) {
        self.likes = data["likes"] as? Int ?? 0
        self.nameOfWriter = data["nameOfWriter"] as? String ?? ""
        self.publicationID = data["publicationID"] as? Int ?? 0
        self.commentText = data["comment"] as? String ?? ""
        self.isLiked = false
    }
}

