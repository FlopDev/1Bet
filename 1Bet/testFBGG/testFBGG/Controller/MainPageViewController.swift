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
    let shared = PublicationService.shared
    var userInfo: User?
    var database = Firestore.firestore()
    let percentOfBKProgressView = ProgressArcView()
    let trustProgressView = ProgressArcView()
    var userID: String? {
        return Auth.auth().currentUser?.uid
    }

    let percentOfBKStackView = UIStackView()
    let trustStackView = UIStackView()
    private var startTime: CFTimeInterval = 0
    private var targetProgress: CGFloat = 0
    private var targetProgressTrustOnTen: CGFloat = 0
    private var duration: TimeInterval = 0
    private var displayLink: CADisplayLink?
    private var bankrollPercentage: CGFloat = 0
    private var trustPercentage: CGFloat = 0
    var publicationID: String = ""

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
    @IBOutlet var likesAndCommentStackView: UIStackView!
    @IBOutlet weak var basketBallImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
        
        downloadLatestImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        loadPublicationAndTchekIfUserAdmin()
    }
    
    func loadPublicationAndTchekIfUserAdmin() {
        let docRef = database.collection("users").document("\(String(describing: Auth.auth().currentUser?.uid))")
        
        PublicationService.shared.getLastPublication { data in
            DispatchQueue.main.async {
                if let data = data {
                    if let colonne1 = data["date"] as? String {
                        print(colonne1)
                        let formattedDate = PublicationService.shared.reversFormatDateString(colonne1)
                        self.dateOfPronostic.text = "Pronostic of : \(formattedDate)"
                    }
                    
                    if let colonne2 = data["description"] as? String {
                        print(colonne2)
                        self.pronosticOfTipsterTextField.text = "Analysis : \(colonne2)"
                    }
                    
                    if let colonne3 = data["percentOfBankroll"] as? String, let percentage = Double(colonne3) {
                        print(colonne3)
                        self.percentOfBkTipsterTextField.text = "% of Bankroll : \(colonne3)"
                        self.bankrollPercentage = CGFloat(percentage)
                        self.setupProgressBarUI(progressView: self.percentOfBKProgressView, targetProgressChoosen: self.bankrollPercentage, progressMaxValue: 100)
                    }
                    
                    if let colonne4 = data["trustOnTen"] as? String, let trustValue = Double(colonne4) {
                        print(colonne4)
                        self.trustOnTenOfTipsterTextField.text = "Trust : \(colonne4)"
                        self.trustPercentage = CGFloat(trustValue)
                        self.setupProgressBarUI(progressView: self.trustProgressView, targetProgressChoosen: self.trustPercentage, progressMaxValue: 10)
                    }
                    PublicationService.shared.getLatestPublicationID { result in
                            switch result {
                            case .success(let documentID):
                                print("ID de la dernière publication : \(documentID)")
                                self.publicationID = documentID
                                self.checkIfUserLiked()
                                self.updateLikesCount()
                            case .failure(let error):
                                print("Erreur : \(error.localizedDescription)")
                                let alert = UIAlertController(title: "ERROR", message: "Cannot retrieve publication ID", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
                let data = document.data()
                let isAdmin = data?["isAdmin"] as! Bool
                print(isAdmin)
                if isAdmin {
                    self.addPronosticButton.isHidden = false
                }
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func pressLikeButton(_ sender: UIButton) {
        guard let userID = userID, !publicationID.isEmpty else { return }
        
        LikeService.shared.toggleLike(for: publicationID, userID: userID) { [weak self] isLiked, error in
            if let error = error {
                print("Erreur lors de l'action de like : \(error.localizedDescription)")
            } else {
                let imageName = isLiked ? "star.fill" : "star"
                DispatchQueue.main.async {
                    sender.setImage(UIImage(systemName: imageName), for: .normal)
                    self?.updateLikesCount()
                }
            }
        }
    }

    
    @IBAction func pressCommentaryButton(_ sender: Any) {
    }

    @IBAction func didPressDisconnect(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            self.performSegue(withIdentifier: "logOut", sender: self)
        } catch let signOutError as NSError {
            UIAlert.presentAlert(from: self, title: "ERROR", message: "Cannot sign out")
        }
    }
    
    // MARK: - Functions
    
    func setUpUI() {
        let customBlurEffect = CustomIntensityVisualEffectView(effect: UIBlurEffect(style: .regular), intensity: 0.00001)
        customBlurEffect.frame = basketBallImage.bounds
        customBlurEffect.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        basketBallImage.addSubview(customBlurEffect)
        
        pronosticOfTipsterTextField.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        likeButton.layer.borderWidth = 1
        commentButton.layer.borderWidth = 1
        likeButton.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        commentButton.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        dateOfPronostic.layer.borderWidth = 1
        dateOfPronostic.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        imageOfPronostic.layer.borderWidth = 1
        imageOfPronostic.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        likeButton.setImage(UIImage(systemName: "star"), for: .normal)
        commentButton.setImage(UIImage(systemName: "bubble.right"), for: .normal)
    }
    
    func downloadLatestImage() {
        FirebaseStorageService.shared.downloadLatestPhoto { image in
            DispatchQueue.main.async {
                if let image = image {
                    self.imageOfPronostic.image = image
                } else {
                    print("Aucune image disponible.")
                }
            }
        }
    }
    
    func updateLikesCount() {
        LikeService.shared.updateLikesCount(for: publicationID) { [weak self] likesCount, error in
            if let error = error {
                print("Erreur lors de la mise à jour du nombre de likes : \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self?.likeButton.setTitle("\(likesCount) likes", for: .normal)
                }
            }
        }
    }

    func checkIfUserLiked() {
        guard let userID = userID, !publicationID.isEmpty else { return }
        
        LikeService.shared.checkIfUserLiked(publicationID: publicationID, userID: userID) { [weak self] isLiked in
            DispatchQueue.main.async {
                let imageName = isLiked ? "star.fill" : "star"
                self?.likeButton.setImage(UIImage(systemName: imageName), for: .normal)
            }
        }
    }

    private func setupProgressBarUI(progressView: ProgressArcView, targetProgressChoosen: CGFloat, progressMaxValue: CGFloat) {
        progressView.translatesAutoresizingMaskIntoConstraints = false

        if progressView == percentOfBKProgressView {
            NSLayoutConstraint.activate([
                progressView.widthAnchor.constraint(equalToConstant: 50),
                progressView.heightAnchor.constraint(equalToConstant: 50)
            ])

            let progressStackView = UIStackView(arrangedSubviews: [percentOfBKProgressView, percentOfBkTipsterTextField])
            progressStackView.axis = .vertical
            progressStackView.spacing = 0
            progressStackView.alignment = .center

            underProgressView.addArrangedSubview(progressStackView)

        } else if progressView == trustProgressView {
            NSLayoutConstraint.activate([
                progressView.widthAnchor.constraint(equalToConstant: 50),
                progressView.heightAnchor.constraint(equalToConstant: 50)
            ])

            let progressStackView2 = UIStackView(arrangedSubviews: [trustProgressView, trustOnTenOfTipsterTextField])
            progressStackView2.axis = .vertical
            progressStackView2.spacing = 0
            progressStackView2.alignment = .center

            underProgressView.addArrangedSubview(progressStackView2)
        }

        underProgressView.spacing = 16
        underProgressView.distribution = .fillEqually
        mainStackView.layer.borderWidth = 1
        mainStackView.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)

        duration = 3.0
        targetProgress = targetProgressChoosen / progressMaxValue
        startTime = CACurrentMediaTime()

        progressView.animateProgress(to: targetProgress, duration: duration) {
            self.displayLink?.invalidate()
            self.displayLink = nil
        }

        displayLink = CADisplayLink(target: self, selector: #selector(updateProgressLabel))
        displayLink?.add(to: .main, forMode: .default)
    }

    @objc private func updateProgressLabel() {
        let elapsedTime = CACurrentMediaTime() - startTime
        if elapsedTime >= duration {
            percentOfBKProgressView.setLabelText("\(Int(bankrollPercentage))%")
            trustProgressView.setLabelText("\(Int(trustPercentage))")
        } else {
            let progressBK = min(CGFloat(elapsedTime / duration) * (bankrollPercentage / 100.0), 1.0)
            let progressTrust = min(CGFloat(elapsedTime / duration) * (trustPercentage / 10.0), 1.0)
            percentOfBKProgressView.setLabelText("\(Int(progressBK * 100))%")
            trustProgressView.setLabelText("\(Int(progressTrust * 10))")
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}
