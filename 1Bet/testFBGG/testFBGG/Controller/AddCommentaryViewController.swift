//
//  AddCommentaryViewController.swift
//  testFBGG
//
//  Created by Florian Peyrony on 14/03/2023.
//

import UIKit
import FirebaseFirestore
import Firebase

class AddCommentaryViewController: UIViewController, UITableViewDelegate {
    
    // MARK: - Properties
    static let cellIdentifier = "CommentCell"
    private let db = Firestore.firestore()
    private var comments: [UserComment] = []
    private let commentService = CommentService()
    var publicationID = ""
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var basketBallImage: UIImageView!
    @IBOutlet weak var publishButton: UIButton!
    
    private let commentContainerView = UIView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupCommentInputView()
        configureBlurEffect()
        
        loadLatestPublicationID()
        setupKeyboardObservers()
    }

    // MARK: - Setup Methods
    
    /// Configures the table view for comments with cell registration and styling.
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CommentCell.self, forCellReuseIdentifier: Self.cellIdentifier)
        tableView.backgroundColor = .clear
    }
    
    /// Adds a blur effect to the background image.
    private func configureBlurEffect() {
        let customBlurEffect = CustomIntensityVisualEffectView(effect: UIBlurEffect(style: .regular), intensity: 0.00001)
        customBlurEffect.frame = basketBallImage.bounds
        customBlurEffect.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        basketBallImage.addSubview(customBlurEffect)
    }
    
    /// Loads the latest publication ID and fetches its comments.
    private func loadLatestPublicationID() {
        PublicationService.shared.getLatestPublicationID { [weak self] result in
            switch result {
            case .success(let documentID):
                self?.publicationID = documentID
                self?.fetchComments()
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    /// Observes keyboard notifications to adjust the view when the keyboard appears or disappears.
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Keyboard Management
    
    @objc private func keyboardWillShow(notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            view.frame.origin.y = -keyboardFrame.height
        }
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        view.frame.origin.y = 0
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Comment Input View Setup
    
    /// Configures the comment input area with a text field, icon, and publish button.
    private func setupCommentInputView() {
        commentContainerView.backgroundColor = UIColor(white: 0.1, alpha: 0.8)
        commentContainerView.layer.cornerRadius = 20
        commentContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        let commentIcon = UIImageView(image: UIImage(systemName: "bubble.left.and.bubble.right.fill"))
        commentIcon.tintColor = .white
        commentIcon.translatesAutoresizingMaskIntoConstraints = false
        
        setupCommentTextField()  // Configures the appearance of the comment text field
        
        publishButton.backgroundColor = UIColor.green
        publishButton.layer.cornerRadius = 10
        publishButton.setTitleColor(.white, for: .normal)
        publishButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(commentContainerView)
        commentContainerView.addSubview(commentIcon)
        commentContainerView.addSubview(commentTextField)
        commentContainerView.addSubview(publishButton)
        
        // Auto Layout constraints
        NSLayoutConstraint.activate([
            commentContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            commentContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            commentContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            commentContainerView.heightAnchor.constraint(equalToConstant: 50),
            
            commentIcon.leadingAnchor.constraint(equalTo: commentContainerView.leadingAnchor, constant: 10),
            commentIcon.centerYAnchor.constraint(equalTo: commentContainerView.centerYAnchor),
            commentIcon.widthAnchor.constraint(equalToConstant: 24),
            commentIcon.heightAnchor.constraint(equalToConstant: 24),
            
            commentTextField.leadingAnchor.constraint(equalTo: commentIcon.trailingAnchor, constant: 10),
            commentTextField.centerYAnchor.constraint(equalTo: commentContainerView.centerYAnchor),
            commentTextField.trailingAnchor.constraint(equalTo: publishButton.leadingAnchor, constant: -10),
            
            publishButton.trailingAnchor.constraint(equalTo: commentContainerView.trailingAnchor, constant: -10),
            publishButton.centerYAnchor.constraint(equalTo: commentContainerView.centerYAnchor),
            publishButton.heightAnchor.constraint(equalToConstant: 40),
            publishButton.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    /// Configures the comment text field's appearance.
    private func setupCommentTextField() {
        commentTextField.backgroundColor = UIColor(white: 0.1, alpha: 0.9)
        commentTextField.textColor = .white
        commentTextField.attributedPlaceholder = NSAttributedString(
            string: "Add a comment...",
            attributes: [NSAttributedString.Key.foregroundColor : UIColor.white]
        )
        commentTextField.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - Actions
    
    /// Dismisses the keyboard when the view is tapped.
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        commentTextField.resignFirstResponder()
    }
    
    /// Publishes a new comment when the publish button is tapped.
    @IBAction func publishButtonTapped(_ sender: UIButton) {
        guard let text = commentTextField.text, !text.isEmpty else {
            presentAlert(title: "Error", message: "Please enter a comment.")
            return
        }
        
        // Publish the comment with the current user information and publication ID
        CommentService.shared.publishComment(
            uid: Auth.auth().currentUser?.uid,
            commentText: text,
            nameOfWriter: Auth.auth().currentUser?.displayName ?? "Anonymous",
            publicationID: publicationID
        )
        
        fetchComments()
        commentTextField.text = ""
        commentTextField.resignFirstResponder()
    }
    
    /// Fetches comments for the current publication and reloads the table view.
    private func fetchComments() {
        CommentService.shared.getCommentsFromPublication(forPublicationID: publicationID) { [weak self] commentsData in
            self?.comments = commentsData.map { data in
                UserComment(nameOfWriter: data["nameOfWriter"] as? String ?? "", commentText: data["commentText"] as? String ?? "")
            }
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Alerts
    
    /// Presents an alert with a title and message.
    private func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Extensions

extension AddCommentaryViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellIdentifier, for: indexPath) as! CommentCell
        cell.configure(with: comments[indexPath.row])
        return cell
    }
}

// MARK: - UserComment Model

struct UserComment {
    var nameOfWriter: String
    var commentText: String
}

// MARK: - Comment Cell

class CommentCell: UITableViewCell {
    
    let usernameLabel = UILabel()
    let commentLabel = UILabel()
    let avatarImageView = UIImageView()
    private let containerView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupCellView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with comment: UserComment) {
        usernameLabel.text = comment.nameOfWriter
        commentLabel.text = comment.commentText
    }
    
    /// Configures the cell's layout and appearance for displaying a comment.
    private func setupCellView() {
        containerView.backgroundColor = UIColor(white: 0.1, alpha: 0.7)
        containerView.layer.cornerRadius = 10
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = 20
        avatarImageView.clipsToBounds = true
        avatarImageView.image = UIImage(systemName: "person.circle.fill")
        avatarImageView.tintColor = .white
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        
        usernameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        usernameLabel.textColor = .white
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        commentLabel.textColor = .lightGray
        commentLabel.numberOfLines = 0
        commentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(containerView)
        containerView.addSubview(avatarImageView)
        containerView.addSubview(usernameLabel)
        containerView.addSubview(commentLabel)
        
        // Auto Layout constraints
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            
            avatarImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            avatarImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 40),
            avatarImageView.heightAnchor.constraint(equalToConstant: 40),
            
            usernameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 10),
            usernameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            
            commentLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 10),
            commentLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 5),
            commentLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            commentLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10)
        ])
    }
}

// MARK: - UITextFieldDelegate Extension

extension AddCommentaryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
