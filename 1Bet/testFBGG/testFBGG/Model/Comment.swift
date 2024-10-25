//
//  Comment.swift
//  testFBGG
//
//  Created by Florian Peyrony on 10/03/2023.
//

import Foundation

struct Comment {
    /// The number of likes the comment has received.
    let likes: Int
    
    /// The name of the person who wrote the comment.
    let nameOfWriter: String
    
    /// The unique identifier for the publication the comment is associated with.
    let publicationID: Int
    
    /// The text content of the comment.
    let commentText: String
    
    /// Indicates if the current user has liked the comment.
    /// This value may be nil if the like status is not available.
    let isLiked: Bool?
    
    /// Initializes a `Comment` instance from a dictionary.
    ///
    /// - Parameter data: A dictionary containing comment data, typically from an API or data source.
    /// - Note: Defaults are provided for missing or invalid data types.
    init(data: [String: Any]) {
        // Attempt to extract the "likes" value as an Int; default to 0 if missing or not an Int
        self.likes = data["likes"] as? Int ?? 0
        
        // Attempt to extract the "nameOfWriter" value as a String; default to an empty string if missing or not a String
        self.nameOfWriter = data["nameOfWriter"] as? String ?? ""
        
        // Attempt to extract the "publicationID" value as an Int; default to 0 if missing or not an Int
        self.publicationID = data["publicationID"] as? Int ?? 0
        
        // Attempt to extract the "comment" value as a String for the comment text; default to an empty string if missing or not a String
        self.commentText = data["comment"] as? String ?? ""
        
        // Attempt to extract the "isLiked" value as a Bool; defaults to false if missing
        self.isLiked = data["isLiked"] as? Bool ?? false
    }
}
