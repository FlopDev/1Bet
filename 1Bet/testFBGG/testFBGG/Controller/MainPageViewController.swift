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
    let curvedProgressView = ProgressArcView()
    let trustProgressView = ProgressArcView()
    
    
    
    private var startTime: CFTimeInterval = 0
    private var targetProgress: CGFloat = 0
    private var targetProgressTrustOnTen: CGFloat = 0
    private var duration: TimeInterval = 0
    private var displayLink: CADisplayLink?
    
    private var bankrollPercentage: CGFloat = 0
    private var trustPercentage: CGFloat = 0
    
    // MARK: - Outlets
    
    @IBOutlet var underProgressView: UIStackView!
    @IBOutlet var mainStackView: UIStackView!
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
    let progressArcView = ProgressArcView()
    let progressArcView2 = ProgressArcView()
    // var progressArcViewPercentOfBK: ProgressArcView()
    // var progressArcViewtrustOnTenOfTipster = ProgressArcView()
    
    
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
        
        likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
        commentButton.setImage(UIImage(systemName: "bubble.right"), for: .normal)
        
        // Vérification si lastItem est disponible
        FirebaseStorageService.shared.downloadPhoto { image in
            DispatchQueue.main.async {
                if let image = image {
                    self.imageOfPronostic.image = image
                } else {
                    print("Aucune image disponible.")
                }
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
                    
                    if let colonne3 = data["percentOfBankroll"] as? String, let percentage = Double(colonne3) {
                        print(colonne3)
                        self.percentOfBkTipsterTextField.text = "% of Bankroll : \(colonne3)"
                        self.bankrollPercentage = CGFloat(percentage)
                        self.setupProgressBarUI(progressView: self.curvedProgressView, targetProgressChoosen: self.bankrollPercentage, progressMaxValue: 100)
                    }
                    
                    if let colonne4 = data["trustOnTen"] as? String, let trustValue = Double(colonne4) {
                        print(colonne4)
                        self.trustOnTenOfTipsterTextField.text = "Trust : \(colonne4)"
                        self.trustPercentage = CGFloat(trustValue)
                        self.setupProgressBarUI(progressView: self.trustProgressView, targetProgressChoosen: self.trustPercentage, progressMaxValue: 10)
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
    
    private func setupProgressBarUI(progressView: ProgressArcView, targetProgressChoosen: CGFloat, progressMaxValue: CGFloat) {
            // Configurez et ajoutez le ProgressArcView à la vue principale
            view.addSubview(progressView)
            progressView.translatesAutoresizingMaskIntoConstraints = false
            
            // Setting constraints differently based on the progress view
            if progressView == curvedProgressView {
                NSLayoutConstraint.activate([
                    progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    progressView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                    progressView.widthAnchor.constraint(equalToConstant: 200),
                    progressView.heightAnchor.constraint(equalToConstant: 200)
                ])
            } else if progressView == trustProgressView {
                NSLayoutConstraint.activate([
                    progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    progressView.topAnchor.constraint(equalTo: curvedProgressView.bottomAnchor, constant: 20),
                    progressView.widthAnchor.constraint(equalToConstant: 200),
                    progressView.heightAnchor.constraint(equalToConstant: 200)
                ])
            }
            
            // Définir les valeurs pour l'animation
            duration = 1.0
            targetProgress = targetProgressChoosen / progressMaxValue
            startTime = CACurrentMediaTime()
            
            // Mettre à jour la progression avec une animation
            progressView.animateProgress(to: targetProgress, duration: duration) {
                self.displayLink?.invalidate()
                self.displayLink = nil
            }
            
            // Créer un CADisplayLink pour mettre à jour le label pendant l'animation
            displayLink = CADisplayLink(target: self, selector: #selector(updateProgressLabel))
            displayLink?.add(to: .main, forMode: .default)
        }

        @objc private func updateProgressLabel() {
            let elapsedTime = CACurrentMediaTime() - startTime
            if elapsedTime >= duration {
                curvedProgressView.setLabelText("\(Int(bankrollPercentage))%")
                trustProgressView.setLabelText("\(Int(trustPercentage))")
            } else {
                let progress = CGFloat(elapsedTime / duration) * targetProgress
                curvedProgressView.setLabelText("\(Int(progress * 100))%")
                trustProgressView.setLabelText("\(Int(progress * 10))")
            }
        }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}
