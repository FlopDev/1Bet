//
//  FirebaseService.swift
//  testFBGG
//
//  Created by Florian Peyrony on 20/01/2023.
//

import Foundation
import Firebase
import FirebaseFirestore
import FacebookLogin
import GoogleSignIn
import FirebaseCore

class FirebaseService {
    
    // MARK: - Preperties
    static let shared = FirebaseService()
    var database = Firestore.firestore()
    let vc = MainPageViewController()
    weak var viewController: UIViewController?
    typealias PublicationCompletion = (String?, String?, Double?, Double?) -> Void
    
    // MARK: - Functions
    func doesEmailExist(email: String, completion: @escaping (Bool) -> Void) {
        // Get a reference to the Firestore database
        //let db = Firestore.firestore()
        // Get a reference to the "users" collection
        let usersRef = database.collection("users")
        // Query the "users" collection for the provided email
        let query = usersRef.whereField("mail", isEqualTo: email)
        
        // Execute the query and get the documents
        query.getDocuments { (snapshot, error) in
            // If there is an error executing the query
            if let error = error {
                // Log the error
                print("Error getting documents: \(error)")
                // Call the completion handler with false
                completion(false)
            } else {
                // If the snapshot is not empty (i.e., the email exists)
                if let snapshot = snapshot, !snapshot.isEmpty {
                    completion(true) // Call the completion handler with true
                } else { // If the snapshot is empty (i.e., the email does not exist)
                    completion(false) // Call the completion handler with false
                }
            }
        }
    }
    
    func checkBDDInfo(completion: @escaping (Bool) -> Void) {
        self.database.collection("users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                print("ERROR IN CHECKBDDINFO FUNCTION")
                // Notification in VC to the user
            } else {
                self.database.collection("users\(String(describing: Auth.auth().currentUser?.uid ?? nil))").getDocuments() { querySnapshot, error in
                    print("On ne trouve pas le UID pour la fonction checkBDDEmailInfo")
                    if querySnapshot != nil {
                        completion(true)
                    } else {
                        self.saveUserInfo(uid:Auth.auth().currentUser?.uid, name: (Auth.auth().currentUser?.displayName)!, email: Auth.auth().currentUser?.email ?? "nil", isAdmin: false)
                        completion(false)
                    }
                }
            }
        }
    }
    
    func signInEmailButton(email: String, username: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard self != nil else { return }
            if error != nil {
                print(error.debugDescription)
                //self.presentAlert(title: "ERROR", message: "Incorrect email or password")
                // add a Notification to show an Alert in the VC
                let nameOfNotification = Notification.Name(rawValue: "FBAnswerFail")
                let notification = Notification(name: nameOfNotification)
                NotificationCenter.default.post(notification)
            } else {
                self!.saveUserInfo(uid: (authResult?.user.email) ?? "nil", name: (authResult?.user.displayName) ?? "nil", email: email, isAdmin: false)
                // successtomain
                let nameOfNotification = Notification.Name(rawValue: "FBAnswerSuccess")
                let notification = Notification(name: nameOfNotification)
                NotificationCenter.default.post(notification)
                
            }
        }
    }
    
    
    func logInEmailButton(email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Erreur lors de la connexion: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Connexion réussie.")
                completion(true)
            }
        }
    }
    
    
    func facebookButton() {
        checkBDDInfo() { result in
            if result {
                // Vérifier si AccessToken.current est nul
                guard let tokenString = AccessToken.current?.tokenString else {
                    print("AccessToken is nil")
                    // Gérer l'erreur ici, par exemple, en affichant un message à l'utilisateur ou en lançant une notification
                    return
                }
                // Utiliser en toute sécurité le tokenString récupéré
                let credential = FacebookAuthProvider.credential(withAccessToken: tokenString)
                
                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        let authError = error as NSError
                        print(authError.localizedDescription)
                        let nameOfNotification = Notification.Name(rawValue: "FBAnswerFail")
                        let notification = Notification(name: nameOfNotification)
                        NotificationCenter.default.post(notification)
                        return
                    }
                    // User is signed in
                    let nameOfNotification = Notification.Name(rawValue: "FBAnswerSuccess")
                    let notification = Notification(name: nameOfNotification)
                    NotificationCenter.default.post(notification)
                }
            } else {
                // Vérifier si AccessToken.current est nul
                guard let tokenString = AccessToken.current?.tokenString else {
                    print("AccessToken is nil")
                    // Gérer l'erreur ici, par exemple, en affichant un message à l'utilisateur ou en lançant une notification
                    return
                }
                // Utiliser en toute sécurité le tokenString récupéré
                let credential = FacebookAuthProvider.credential(withAccessToken: tokenString)
                
                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        let authError = error as NSError
                        print(authError.localizedDescription)
                        let nameOfNotification = Notification.Name(rawValue: "FBAnswerFail")
                        let notification = Notification(name: nameOfNotification)
                        NotificationCenter.default.post(notification)
                        return
                    }
                    // User is signed in
                    let nameOfNotification = Notification.Name(rawValue: "FBAnswerSuccess")
                    let notification = Notification(name: nameOfNotification)
                    NotificationCenter.default.post(notification)
                    self.saveUserInfo(uid:authResult!.user.uid, name: (authResult?.user.displayName)!, email: authResult?.user.email ?? "nil", isAdmin: false)
                }
            }
        }
    }
    
    
    func signInByGmail(viewController: UIViewController) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(with: config, presenting: viewController) { [unowned self] user, error in
            
            if let error = error {
                // ...
                return
            }
            
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                return
            }
            
            let credential: AuthCredential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
            
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    let nameOfNotification = Notification.Name(rawValue: "FBAnswerFail")
                    let notification = Notification(name: nameOfNotification)
                    NotificationCenter.default.post(notification)
                    // self.showMessagePrompt(error.localizedDescription)
                    
                }
                // User is signed in
                // ...
                let nameOfNotification = Notification.Name(rawValue: "FBAnswerSuccess")
                let notification = Notification(name: nameOfNotification)
                NotificationCenter.default.post(notification)
                
                self.saveUserInfo(uid:authResult!.user.uid, name: (authResult?.user.displayName)!, email: authResult?.user.email ?? "nil", isAdmin: false)
            }
        }
    }
    
    func saveUserInfo(uid: String?, name: String, email: String, isAdmin: Bool) {
        let docRef = database.document("users/\(String(describing: uid))")
        docRef.setData(["name": name, "mail": email, "isAdmin": isAdmin])
    }
}
