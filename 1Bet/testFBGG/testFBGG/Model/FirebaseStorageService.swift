//
//  FirebaseStoragePicture.swift
//  testFBGG
//
//  Created by Florian Peyrony on 12/05/2024.
//

import Foundation
import FirebaseStorage
import UIKit

class FirebaseStorageService {
    
    static let shared = FirebaseStorageService()
    let storage = Storage.storage()
    
    // MARK: - Vincent : => pourquoi j'peux pas la static ?
    // Fonction pour ajouter une photo à Firebase Storage
    func uploadPhoto(image: UIImage, completion: @escaping (Error?) -> Void) {
        // Vérifie que les données de l'image sont valides
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion(FirebaseStorageError.invalidImageData)
            return
        }
        
        // Référence au stockage Firebase
        let storageRef = storage.reference()
        // Création d'une référence pour la photo avec un nom unique
        let photoRef = storageRef.child("photos/\(UUID().uuidString).jpg")
        
        // Téléchargement des données de l'image sur Firebase Storage
        let _ = photoRef.putData(imageData, metadata: nil) { (metadata, error) in
            if let error = error {
                // En cas d'erreur lors du téléchargement, renvoie l'erreur
                completion(error)
            } else {
                // Si le téléchargement est réussi, appelle le completion handler sans erreur
                completion(nil)
            }
        }
    }
    
    func getImagesFromFirebaseStorage(completion: @escaping (StorageReference?) -> Void) {
        // Référence à la collection Firebase Storage "photos"
        let storageRef = Storage.storage().reference().child("photos")
        
        // Récupération de la liste des fichiers dans la collection
        storageRef.listAll { (result, error) in
            if let error = error {
                print("Erreur lors de la récupération des images: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            // Nombre total d'éléments à télécharger
            let totalCount = result!.items.count
            
            // Variable pour suivre le nombre d'éléments téléchargés avec succès
            var downloadedCount = 0
            
            // Parcourir chaque élément dans la liste
            for item in result!.items {
                // Télécharger l'image correspondante à chaque élément
                item.getData(maxSize: 10 * 1024 * 1024) { data, error in
                    if let error = error {
                        print("Erreur lors du téléchargement de l'image: \(error.localizedDescription)")
                        completion(nil)
                        return
                    }
                    
                    // Incrémenter le compteur d'éléments téléchargés avec succès
                    downloadedCount += 1
                    
                    // Vérifier si toutes les images ont été téléchargées avec succès
                    if downloadedCount == totalCount {
                        // Renvoyer l'élément "last" une fois que toutes les images ont été téléchargées
                        completion(result!.items.last)
                        
                    }
                }
            }
        }
    }
}

enum FirebaseStorageError: Error {
    case invalidImageData
    case downloadURLNotFound
}
