//
//  MainPageViewController.swift
//  testFBGG
//
//  Created by Florian Peyrony on 05/12/2022.
//

import UIKit
import FirebaseFirestore
import Firebase


class MainPageViewController: UIViewController {
    
    // MARK: - Properties
    var userInfo: User?
    var database = Firestore.firestore()
    
    // MARK: - Outlets
    
    @IBOutlet weak var addPronosticButton: UIButton!
    @IBOutlet weak var dateOfPronostic: UILabel!
    @IBOutlet weak var imageOfPronostic: UIImageView!
    
    @IBOutlet weak var pronosticOfTipsterTextField: UILabel!
    @IBOutlet weak var trustOnTenOfTipsterTextField: UILabel!
    @IBOutlet weak var percentOfBkTipsterTextField: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var disconnectButton: UIButton!
    @IBOutlet weak var basketBallImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let customBlurEffect = CustomIntensityVisualEffectView(effect: UIBlurEffect(style: .regular), intensity: 0.00001)
        customBlurEffect.frame = basketBallImage.bounds
        customBlurEffect.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        basketBallImage.addSubview(customBlurEffect)
        
        // margin of bet pronostic
        pronosticOfTipsterTextField.setMargins()
        pronosticOfTipsterTextField.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        likeButton.layer.borderWidth = 1
        commentButton.layer.borderWidth = 1
        likeButton.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        commentButton.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        // Vérification si lastItem est disponible
        FirebaseStorageService.shared.getImagesFromFirebaseStorage { lastItem in
            // Vérification si lastItem est disponible
            if let lastItem = lastItem {
                // Téléchargement de l'image correspondant à lastItem
                lastItem.getData(maxSize: 10 * 1024 * 1024) { data, error in
                    if let error = error {
                        print("Erreur lors du téléchargement de l'image: \(error.localizedDescription)")
                        UIAlert.presentAlert(from: self, title: "ERROR", message: "Cannot retrieve image")
                        return
                    }
                    
                    // Vérification si des données d'image ont été téléchargées
                    guard let imageData = data else {
                        print("Aucune donnée d'image téléchargée.")
                        UIAlert.presentAlert(from: self, title: "ERROR", message: "Cannot retrieve image")
                        return
                    }
                    
                    // Création d'une UIImage à partir des données téléchargées
                    if let image = UIImage(data: imageData) {
                        // Mise à jour de l'UIImageView avec l'image téléchargée
                        DispatchQueue.main.async {
                            self.imageOfPronostic.image = image
                        }
                    }
                }
            } else {
                print("Aucun élément n'a été téléchargé.")
                UIAlert.presentAlert(from: self, title: "ERROR", message: "No element download")
            }
        }
    }
    
    // MARK: - Functions
    
    override func viewWillAppear(_ animated: Bool) {
        //to know if the user logged is An Admin
        
        let db = Firestore.firestore()
        let docRef = db.collection("users").document("\(String(describing: Auth.auth().currentUser?.uid))")
        
        PublicationService.shared.getLastPublication { data in
            // Manipuler les données récupérées ici dans la file principale
            DispatchQueue.main.async {
                if let data = data {
                    // Utilisez les données dans votre ViewController
                    if let colonne1 = data["date"] as? String {
                        print(colonne1)
                        self.dateOfPronostic.text = "Pronostic of : \(colonne1)"
                    }
                    
                    if let colonne2 = data["description"] as? String {
                        print(colonne2)
                        self.pronosticOfTipsterTextField.text = "Anaysis : \(colonne2)"
                        self.pronosticOfTipsterTextField.setMargins()
                    }
                    
                    if let colonne3 = data["percentOfBankroll"] as? String {
                        print(colonne3)
                        self.percentOfBkTipsterTextField.text = "% of Bankroll : \(colonne3)"
                    }
                    
                    if let colonne4 = data["trustOnTen"] as? String {
                        print(colonne4)
                        self.trustOnTenOfTipsterTextField.text = "Trust : \(colonne4)"
                    }
                } else {
                    UIAlert.presentAlert(from: self, title: "ERROR", message: "Cannot retrieve data")
                    print("Aucune donnée récupérée.")
                }
            }
        }
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
                print(dataDescription)
                // print("\(dataDescription["isAdmin"])")
                let data = document.data()
                let isAdmin = data?["isAdmin"] as! Bool
                print(isAdmin)
                if isAdmin == true {
                    self.addPronosticButton.isHidden = false
                }
                
            } else {
                UIAlert.presentAlert(from: self, title: "ERROR", message: "Document does not exist")
                print("Document does not exist")
            }
        }
        // doownload the image of the last bet
        
    }
    
    @IBAction func pressLikeButton(_ sender: Any) {
    }
    
    @IBAction func pressCommentaryButton(_ sender: Any) {
    }
    @IBAction func didPressDisconnect(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            // segue To signIn
            self.performSegue(withIdentifier: "logOut", sender: self)
        } catch let signOutError as NSError {
            UIAlert.presentAlert(from: self, title: "ERROR", message: "Cannot sign out")
            print("Error signing out: %@", signOutError)
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}
