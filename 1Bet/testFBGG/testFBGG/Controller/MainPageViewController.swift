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

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUIElements()
        loadLatestImage()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadUserData()
        loadPublicationData()
    }
    
    // MARK: - UI Setup

    /// Sets up UI styles for buttons, labels, and background blur effect
    private func setupUIElements() {
        // Apply blur effect to basketball image
        let customBlurEffect = CustomIntensityVisualEffectView(effect: UIBlurEffect(style: .regular), intensity: 0.00001)
        customBlurEffect.frame = basketBallImage.bounds
        customBlurEffect.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        basketBallImage.addSubview(customBlurEffect)
        
        // Style text fields and buttons
        pronosticOfTipsterTextField.textColor = .white
        setupButtonBorders(button: likeButton, borderColor: .white, imageName: "star")
        setupButtonBorders(button: commentButton, borderColor: .white, imageName: "bubble.right")
        setupLabelBorders(label: dateOfPronostic, borderColor: .white)
        setupLabelBorders(label: imageOfPronostic, borderColor: .white)
    }

    /// Sets up border style and image for UIButton
    private func setupButtonBorders(button: UIButton, borderColor: UIColor, imageName: String) {
        button.layer.borderWidth = 1
        button.layer.borderColor = borderColor.cgColor
        button.setImage(UIImage(systemName: imageName), for: .normal)
    }

    /// Sets up border style for UILabel
    private func setupLabelBorders(label: UIView, borderColor: UIColor) {
        label.layer.borderWidth = 1
        label.layer.borderColor = borderColor.cgColor
    }
    
    // MARK: - Data Loading

    /// Downloads and sets the latest image from Firebase storage
    private func loadLatestImage() {
        FirebaseStorageService.shared.downloadLatestPhoto { [weak self] image in
            DispatchQueue.main.async {
                self?.imageOfPronostic.image = image ?? UIImage(systemName: "photo")
            }
        }
    }

    /// Loads and configures user data from Firestore
    private func loadUserData() {
        let docRef = database.collection("users").document("\(userID ?? "")")
        
        docRef.getDocument { [weak self] (document, error) in
            guard let self = self, let document = document, document.exists else { return }
            if let isAdmin = document.data()?["isAdmin"] as? Bool {
                self.addPronosticButton.isHidden = !isAdmin
            }
        }
    }

    /// Loads the last publication data and updates the UI accordingly
    private func loadPublicationData() {
        PublicationService.shared.getLastPublication { [weak self] data in
            DispatchQueue.main.async {
                guard let self = self, let data = data else { return }
                self.updatePublicationUI(with: data)
                
                PublicationService.shared.getLatestPublicationID { result in
                    switch result {
                    case .success(let documentID):
                        self.publicationID = documentID
                        self.checkIfUserLiked()
                        self.updateLikesCount()
                    case .failure(let error):
                        self.showAlert(title: "ERROR", message: "Cannot retrieve publication ID: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    /// Updates the UI based on the last publication data
    private func updatePublicationUI(with data: [String: Any]) {
        if let dateStr = data["date"] as? String {
            dateOfPronostic.text = "Pronostic of : \(PublicationService.shared.reversFormatDateString(dateStr))"
        }
        
        if let description = data["description"] as? String {
            pronosticOfTipsterTextField.text = "Analysis : \(description)"
        }
        
        if let percentStr = data["percentOfBankroll"] as? String, let percentage = Double(percentStr) {
            percentOfBkTipsterTextField.text = "% of Bankroll : \(percentStr)"
            bankrollPercentage = CGFloat(percentage)
            setupProgressBarUI(progressView: percentOfBKProgressView, targetProgressChoosen: bankrollPercentage, progressMaxValue: 100)
        }
        
        if let trustStr = data["trustOnTen"] as? String, let trustValue = Double(trustStr) {
            trustOnTenOfTipsterTextField.text = "Trust : \(trustStr)"
            trustPercentage = CGFloat(trustValue)
            setupProgressBarUI(progressView: trustProgressView, targetProgressChoosen: trustPercentage, progressMaxValue: 10)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func pressCommentaryButton(_ sender: Any) {
        // Action to handle commentary button tap
        print("Commentary button pressed")
    }

    
    /// Toggles like status for the current publication
    @IBAction func pressLikeButton(_ sender: UIButton) {
        guard let userID = userID, !publicationID.isEmpty else { return }
        
        LikeService.shared.toggleLike(for: publicationID, userID: userID) { [weak self] isLiked, error in
            if let error = error {
                print("Error toggling like: \(error.localizedDescription)")
            } else {
                let imageName = isLiked ? "star.fill" : "star"
                DispatchQueue.main.async {
                    sender.setImage(UIImage(systemName: imageName), for: .normal)
                    self?.updateLikesCount()
                }
            }
        }
    }
    
    /// Disconnects the user and performs logout segue
    @IBAction func didPressDisconnect(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: "logOut", sender: self)
        } catch let signOutError as NSError {
            showAlert(title: "ERROR", message: "Cannot sign out: \(signOutError.localizedDescription)")
        }
    }
    
    // MARK: - Helper Methods
    
    /// Updates the likes count for the current publication
    private func updateLikesCount() {
        LikeService.shared.updateLikesCount(for: publicationID) { [weak self] likesCount, error in
            if let error = error {
                print("Error updating likes count: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self?.likeButton.setTitle("\(likesCount) likes", for: .normal)
                }
            }
        }
    }

    /// Checks if the current user has liked the publication and updates the button image
    private func checkIfUserLiked() {
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
            mainStackView.layer.borderColor = UIColor.white.cgColor


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
    
    /// Shows an alert with the given title and message
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Pass data to the new view controller if needed
    }
}
