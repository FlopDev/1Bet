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
    
    func getLastPublication(completion: @escaping ([String: Any]?) -> Void) {
            let collectionRef = database.collection("publication")

            // Tri des documents par date de publication
            let query = collectionRef.order(by: "date", descending: true).limit(to: 1)

            // Exécution de la requête
            query.getDocuments { (snapshot, error) in
                if let error = error {
                    print("Erreur lors de la récupération des données : \(error.localizedDescription)")
                    completion(nil)
                    return
                }

                // Traitement des données ici avec snapshot
                if let document = snapshot?.documents.first {
                    // Vous avez maintenant le dernier document dans la variable 'document'
                    let data = document.data()
                    completion(data)
                } else {
                    print("Aucune publication trouvée.")
                    completion(nil)
                }
            }
        }
}
