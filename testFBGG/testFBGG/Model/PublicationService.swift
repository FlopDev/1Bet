//
//  PublicationService.swift
//  testFBGG
//
//  Created by Florian Peyrony on 24/03/2023.
//

import Foundation
import Firebase
import FirebaseFirestore
import FacebookLogin
import GoogleSignIn


class PublicationService {
    
    // MARK: - Preperties
    static let shared = PublicationService()
    var database = Firestore.firestore()
    
    // MARK: - Functions
    
    func savePublicationOnDB(date: String, description: String, percentOfBankroll: String, publicationID: Int, trustOnTen: String) {
        let docRef = database.collection("publication").document()
        docRef.setData(["date": date, "description": description, "percentOfBankroll": percentOfBankroll, "trustOnTen": trustOnTen])
    }
}
