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
    
    // pourquoi ca fait crash l'app ?
   //let firebaseService = FirebaseService()
    
    
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
        
    }
    
    // MARK: - Functions
    
    override func viewWillAppear(_ animated: Bool) {
        //to know if the user logged is An Admin
        
        let db = Firestore.firestore()
        let docRef = db.collection("users").document("\(String(describing: Auth.auth().currentUser?.uid))")
        
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
                print("Document does not exist")
            }
        }
    }
    
    @IBAction func pressLikeButton(_ sender: Any) {
    }
    
    @IBAction func pressCommentaryButton(_ sender: Any) {
    }
    @IBAction func didPressDisconnect(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
            // segue Ton signIn
            self.performSegue(withIdentifier: "logOut", sender: self)
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
    }
    
        // MARK: - Navigation

   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       // Get the new view controller using segue.destination.
       // Pass the selected object to the new view controller.
   }
    
        // MARK: - Alerts
        
        func presentAlert(title: String, message: String) {
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
}
