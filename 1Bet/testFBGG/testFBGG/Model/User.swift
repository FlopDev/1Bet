//
//  User.swift
//  testFBGG
//
//  Created by Florian Peyrony on 23/05/2023.
//

import Foundation

struct User {
    /// Indicates if the user has administrative privileges.
    let isAdmin: Bool
    
    /// The email address of the user.
    let mail: String
    
    /// The name of the user.
    let name: String
    
    /// Initializes a `User` instance from a dictionary.
    ///
    /// - Parameter data: A dictionary containing user information, typically from an API or data source.
    /// - Note: If any expected key is missing or contains an invalid type, a default value is used.
    init(data: [String: Any]) {
        // Attempt to extract the "isAdmin" value as a Bool; default to false if missing or not a Bool
        self.isAdmin = data["isAdmin"] as? Bool ?? false
        
        // Attempt to extract the "mail" value as a String; default to an empty string if missing or not a String
        self.mail = data["mail"] as? String ?? ""
        
        // Attempt to extract the "name" value as a String; default to an empty string if missing or not a String
        self.name = data["name"] as? String ?? ""
    }
}

