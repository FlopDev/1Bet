//
//  PublicationService.swift
//  testFBGG
//
//  Created by Florian Peyrony on 24/03/2023.
//

import Foundation
import Firebase
import FirebaseFirestore

class PublicationService {
    
    // MARK: - Properties
    
    /// Singleton instance of `PublicationService` for easy access across the app.
    static let shared = PublicationService()
    
    /// Reference to the Firestore database.
    var database = Firestore.firestore()
    
    // MARK: - Functions
    
    /// Saves a new publication to Firestore with the provided details.
    ///
    /// - Parameters:
    ///   - date: The date of the publication in "dd/MM/yyyy" format.
    ///   - description: A brief description of the publication content.
    ///   - percentOfBankroll: The percentage of bankroll associated with the publication.
    ///   - publicationID: Unique identifier for the publication.
    ///   - trustOnTen: Trust level (on a scale of ten) for the publication.
    func savePublicationOnDB(date: String, description: String, percentOfBankroll: String, publicationID: String, trustOnTen: String) {
        let formattedDate = formatDateString(date)
        let docRef = database.collection("publication").document(publicationID)
        
        // Set the document data with necessary fields
        docRef.setData([
            "date": formattedDate,
            "description": description,
            "percentOfBankroll": percentOfBankroll,
            "trustOnTen": trustOnTen,
            "likes": 0
        ])
    }

    /// Formats a date string from "dd/MM/yyyy" to "yyyy-MM-dd".
    ///
    /// - Parameter date: A date string in "dd/MM/yyyy" format.
    /// - Returns: A formatted date string in "yyyy-MM-dd" format if valid; otherwise, returns the original string.
    func formatDateString(_ date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        if let dateObject = dateFormatter.date(from: date) {
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter.string(from: dateObject)
        }
        return date
    }
    
    
    func reversFormatDateString(_ date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let dateObject = dateFormatter.date(from: date) {
            dateFormatter.dateFormat = "dd/MM/yyyy"
            return dateFormatter.string(from: dateObject)
        }
        return date
    }
    
    /// Fetches the ID of the latest publication, based on the most recent date.
    ///
    /// - Parameter completion: Completion handler returning the latest publication ID or an error.
    func getLatestPublicationID(completion: @escaping (Result<String, Error>) -> Void) {
        let collectionRef = database.collection("publication")
        collectionRef.order(by: "date", descending: true).limit(to: 1).getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let document = querySnapshot?.documents.first {
                let documentID = document.documentID
                completion(.success(documentID))
            } else {
                completion(.failure(FirebaseStorageError.noDocumentsFound))
            }
        }
    }
    
    /// Retrieves the most recent publication details.
    ///
    /// - Parameter completion: Completion handler returning a dictionary of publication details or `nil` if an error occurs.
    func getLastPublication(completion: @escaping ([String: Any]?) -> Void) {
        let collectionRef = database.collection("publication")
        let query = collectionRef.order(by: "date", descending: true).limit(to: 1)
        query.getDocuments { (snapshot, error) in
            if error != nil {
                completion(nil)
                return
            }
            guard let document = snapshot?.documents.first else {
                completion(nil)
                return
            }
            let data = document.data()
            guard data["date"] is String else {
                completion(nil)
                return
            }
            completion(data)
        }
    }
}
