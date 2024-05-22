//
//  FirebaseStoragePicture.swift
//  testFBGG
//
//  Created by Florian Peyrony on 12/05/2024.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore
import UIKit

class FirebaseStorageService {
    
    static let shared = FirebaseStorageService()
    let storage = Storage.storage()
    private let firestore = Firestore.firestore()
    
    // Fonction pour télécharger une photo depuis Firebase Storage
    func downloadPhoto(completion: @escaping (UIImage?) -> Void) {
        // Référence au dossier "photos" dans Firebase Storage
        let storageRef = Storage.storage().reference(withPath: "photos")
        
        // Liste tous les éléments dans le dossier "photos"
        storageRef.listAll { (result, error) in
            // Gère les erreurs de la liste
            if let error = error {
                print("Erreur lors de la liste des fichiers: \(error)")
                completion(nil)
                return
            }
            
            // Vérifie s'il y a des fichiers dans le dossier
            guard let items = result?.items, !items.isEmpty else {
                print("Aucun fichier trouvé")
                completion(nil)
                return
            }
            
            // Variables pour suivre l'élément le plus récent
            var mostRecentItem: StorageReference?
            var mostRecentDate: Date?
            
            // Groupe pour gérer les appels asynchrones
            let dispatchGroup = DispatchGroup()
            
            // Parcourt chaque fichier pour obtenir les métadonnées
            for item in items {
                dispatchGroup.enter() // Indique qu'un travail commence
                
                // Obtient les métadonnées de chaque fichier
                item.getMetadata { metadata, error in
                    // Vérifie s'il y a des métadonnées et une date de mise à jour
                    if let metadata = metadata, let updated = metadata.updated {
                        // Met à jour l'élément le plus récent si nécessaire
                        if mostRecentDate == nil || updated > mostRecentDate! {
                            mostRecentDate = updated
                            mostRecentItem = item
                        }
                    }
                    dispatchGroup.leave() // Indique que le travail est terminé
                }
            }
            
            // Appelé une fois que tous les appels asynchrones sont terminés
            dispatchGroup.notify(queue: .main) {
                // Vérifie s'il y a un élément le plus récent
                guard let mostRecentItem = mostRecentItem else {
                    print("Impossible de trouver le fichier le plus récent")
                    completion(nil)
                    return
                }
                
                // Télécharge les données de l'image la plus récente
                mostRecentItem.getData(maxSize: 10 * 1024 * 1024) { data, error in
                    // Gère les erreurs de téléchargement
                    if let error = error {
                        print("Erreur lors du téléchargement de l'image: \(error)")
                        completion(nil)
                        return
                    }
                    
                    // Convertit les données en UIImage et appelle le completion handler
                    if let data = data, let image = UIImage(data: data) {
                        completion(image)
                    } else {
                        completion(nil)
                    }
                }
            }
        }
    }
    
    // Fonction pour envoyer une photo vers Firebase Storage
    func uploadPhoto(image: UIImage, completion: @escaping (Error?) -> Void) {
        // Convertir l'image en données JPEG
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion(FirebaseStorageError.invalidImageData)
            return
        }
        
        // Créer une référence unique pour l'image dans Firebase Storage
        let storageRef = storage.reference()
        let photoRef = storageRef.child("photos/\(UUID().uuidString).jpg")
        
        // Télécharger l'image dans Firebase Storage
        let _ = photoRef.putData(imageData, metadata: nil) { (metadata, error) in
            if let error = error {
                completion(error)
                return
            }
            
            // Enregistrer les données de base dans Firestore sans l'URL de téléchargement
            let documentData: [String: Any] = [
                "date": Timestamp(date: Date())
            ]
            
            self.firestore.collection("photos").addDocument(data: documentData) { error in
                completion(error)
            }
        }
    }
}

enum FirebaseStorageError: Error {
    case invalidImageData
    case downloadURLNotFound
}
