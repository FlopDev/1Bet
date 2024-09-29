//
//  User.swift
//  testFBGG
//
//  Created by Florian Peyrony on 23/05/2023.
//

import Foundation

struct User {
    let isAdmin: Bool
    let mail: String
    let name: String
    
    init(data: [String: Any]) {
        self.isAdmin = data["isAdmin"] as? Bool ?? false
        self.mail = data["mail"] as? String ?? ""
        self.name = data["name"] as? String ?? ""
    }
}
