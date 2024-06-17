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
    
    func savePublicationOnDB(date: String, description: String, percentOfBankroll: String, publicationID: String, trustOnTen: String) {
        // Convertir la date en format YYYY-MM-DD si nécessaire
        let formattedDate = formatDateString(date)
        let docRef = database.collection("publication").document()
        docRef.setData(["date": formattedDate, "description": description, "percentOfBankroll": percentOfBankroll, "trustOnTen": trustOnTen])
    }

    func formatDateString(_ date: String) -> String {
        // Implémentez ici la conversion de votre format de date actuel en format YYYY-MM-DD
        // Exemple de conversion si le format actuel est DD/MM/YYYY
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        if let dateObject = dateFormatter.date(from: date) {
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter.string(from: dateObject)
        }
        return date // Retourne la date originale si la conversion échoue
    }
    
    func getLatestPublicationID(completion: @escaping (Result<String, Error>) -> Void) {
        let collectionRef = database.collection("publication")
        
        // Récupère le dernier document ajouté dans la collection "publication"
        collectionRef.order(by: "date", descending: true).limit(to: 1).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Erreur lors de la récupération des données : \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            // Vérifie que le document existe et renvoie son ID
            if let document = querySnapshot?.documents.first {
                let documentID = document.documentID
                completion(.success(documentID))
            } else {
                print("Aucune publication trouvée.")
                completion(.failure(FirebaseStorageError.noDocumentsFound))
            }
        }
    }
    
    func getLastPublication(completion: @escaping ([String: Any]?) -> Void) {
        let collectionRef = database.collection("publication")
        
        let query = collectionRef.order(by: "date", descending: true).limit(to: 1)
        
        query.getDocuments { (snapshot, error) in
            if let error = error {
                print("Erreur lors de la récupération des données : \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let document = snapshot?.documents.first else {
                print("Aucune publication trouvée.")
                completion(nil)
                return
            }
            
            let data = document.data()
            
            // Vérification de l'existence du champ "date"
            guard let date = data["date"] as? String else {
                print("Le champ 'date' est manquant ou n'est pas au format attendu.")
                completion(nil)
                return
            }
            
            completion(data)
        }
    }

}
