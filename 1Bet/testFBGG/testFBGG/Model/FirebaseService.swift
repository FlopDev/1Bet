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
import FirebaseAuth
import GoogleSignIn

import FirebaseCore
import AppAuth

class FirebaseService {
    
    // MARK: - Preperties
    static let shared = FirebaseService()
    var database = Firestore.firestore()
    let vc = MainPageViewController()
    weak var viewController: UIViewController?
    typealias PublicationCompletion = (String?, String?, Double?, Double?) -> Void
    
    // MARK: - Functions
    /// Checks if an email already exists in the Firestore `users` collection.
    ///
    /// - Parameters:
    ///   - email: The email to check.
    ///   - completion: A completion handler returning `true` if the email exists, `false` otherwise.
    func doesEmailExist(email: String, completion: @escaping (Bool) -> Void) {
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
    
    /// Checks if the user's information exists in Firestore. If not, saves new user info.
    ///
    /// - Parameter completion: A completion handler returning `true` if user info exists, `false` otherwise.
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
    
    /// Signs in a user with email and password.
    ///
    /// - Parameters:
    ///   - email: The user's email.
    ///   - username: The user's username.
    ///   - password: The user's password.
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
    
    /// Logs in a user with email and password.
        ///
        /// - Parameters:
        ///   - email: The user's email.
        ///   - password: The user's password.
        ///   - completion: A completion handler returning `true` on success, `false` on failure.
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
    
    /// Authenticates a user with Facebook.
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
    /// Signs in a user with Google.
        ///
        /// - Parameter viewController: The view controller that presents the sign-in.
    func signInByGmail(viewController: UIViewController) {
        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { signInResult, error in
            if let error = error {
                // Gérer l'erreur
                let nameOfNotification = Notification.Name(rawValue: "FBAnswerFail")
                let notification = Notification(name: nameOfNotification)
                NotificationCenter.default.post(notification)
                return
            }

            guard let signInResult = signInResult else {
                return
            }

            // Rafraîchir les tokens si nécessaire
            signInResult.user.refreshTokensIfNeeded { user, error in
                if let error = error {
                    // Gérer l'erreur de rafraîchissement du token
                    let nameOfNotification = Notification.Name(rawValue: "FBAnswerFail")
                    let notification = Notification(name: nameOfNotification)
                    NotificationCenter.default.post(notification)
                    return
                }

                guard let user = user else {
                    return
                }

                guard let idToken = user.idToken?.tokenString else {
                    // Gérer le cas où idToken est nil
                    return
                }

                let accessToken = user.accessToken.tokenString

                // Utiliser l'ID Token et l'Access Token pour s'authentifier auprès de Firebase
                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        // Gérer l'erreur d'authentification Firebase
                        let nameOfNotification = Notification.Name(rawValue: "FBAnswerFail")
                        let notification = Notification(name: nameOfNotification)
                        NotificationCenter.default.post(notification)
                        return
                    }

                    // Authentification réussie
                    let nameOfNotification = Notification.Name(rawValue: "FBAnswerSuccess")
                    let notification = Notification(name: nameOfNotification)
                    NotificationCenter.default.post(notification)

                    // Sauvegarder les infos de l'utilisateur
                    if let authResult = authResult {
                        self.saveUserInfo(uid: authResult.user.uid, name: authResult.user.displayName ?? "", email: authResult.user.email ?? "nil", isAdmin: false)
                    }
                }
            }
        }
    }

    /// Saves user information in Firestore.
        ///
        /// - Parameters:
        ///   - uid: The unique identifier for the user.
        ///   - name: The user's name.
        ///   - email: The user's email.
        ///   - isAdmin: A boolean indicating if the user has admin privileges.
    func saveUserInfo(uid: String?, name: String, email: String, isAdmin: Bool) {
        let docRef = database.document("users/\(String(describing: uid))")
        docRef.setData(["name": name, "mail": email, "isAdmin": isAdmin])
    }
}
