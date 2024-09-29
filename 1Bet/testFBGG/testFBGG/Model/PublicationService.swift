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
    static let shared = PublicationService()
    var database = Firestore.firestore()
    
    // MARK: - Functions
    
    func savePublicationOnDB(date: String, description: String, percentOfBankroll: String, publicationID: String, trustOnTen: String) {
        let formattedDate = formatDateString(date)
        let docRef = database.collection("publication").document(publicationID)
        docRef.setData(["date": formattedDate, "description": description, "percentOfBankroll": percentOfBankroll, "trustOnTen": trustOnTen, "likesCount": 0, "likes": [:]])
    }

    func formatDateString(_ date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        if let dateObject = dateFormatter.date(from: date) {
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter.string(from: dateObject)
        }
        return date
    }
    
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
    
    func toggleLike(publicationID: String, userID: String, completion: @escaping (Result<Int, Error>) -> Void) {
        let docRef = database.collection("publication").document(publicationID)
        let userLikeRef = docRef.collection("likes").document(userID)
        
        database.runTransaction({ (transaction, errorPointer) -> Any? in
            let publicationDocument: DocumentSnapshot
            do {
                try publicationDocument = transaction.getDocument(docRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let oldLikesCount = publicationDocument.data()?["likesCount"] as? Int else {
                return nil
            }
            
            let likesData = publicationDocument.data()?["likes"] as? [String: Bool] ?? [:]
            let hasLiked = likesData[userID] ?? false
            
            if hasLiked {
                transaction.updateData(["likesCount": oldLikesCount - 1], forDocument: docRef)
                transaction.updateData(["likes.\(userID)": FieldValue.delete()], forDocument: docRef)
                transaction.deleteDocument(userLikeRef)
                completion(.success(oldLikesCount - 1))
            } else {
                transaction.updateData(["likesCount": oldLikesCount + 1], forDocument: docRef)
                transaction.updateData(["likes.\(userID)": true], forDocument: docRef)
                transaction.setData([:], forDocument: userLikeRef)
                completion(.success(oldLikesCount + 1))
            }
            return nil
        }) { (object, error) in
            if let error = error {
                completion(.failure(error))
            }
        }
    }
    
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
