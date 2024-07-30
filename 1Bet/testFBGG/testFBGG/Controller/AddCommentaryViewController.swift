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
    static var cellIdentifier = "CommentCell"
    let db = Firestore.firestore()
    var comments: [UserComment] = []
    let commentService = CommentService()
    var publicationID = ""
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var basketBallImage: UIImageView!
    @IBOutlet weak var publishButton: UIButton! // Assuming you have a publish button outlet

    let commentContainerView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CommentCell.self, forCellReuseIdentifier: AddCommentaryViewController.cellIdentifier)
        tableView.backgroundColor = .clear

        setupCommentInputView()
        
        PublicationService.shared.getLatestPublicationID { result in
            switch result {
            case .success(let documentID):
                print("ID de la dernière publication : \(documentID)")
                
                self.publicationID = documentID
                self.commentService.getComments(forPublicationID: self.publicationID) { comments in
                    if comments.isEmpty {
                        print("No comments found for publicationID: \(self.publicationID)")
                    } else {
                        self.comments = comments.map { comment in
                            UserComment(
                                nameOfWriter: comment.nameOfWriter,
                                commentText: comment.commentText
                            )
                        }
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
            case .failure(let error):
                print("Erreur : \(error.localizedDescription)")
            }
        }
        
        let customBlurEffect = CustomIntensityVisualEffectView(effect: UIBlurEffect(style: .regular), intensity: 0.00001)
        customBlurEffect.frame = basketBallImage.bounds
        customBlurEffect.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        basketBallImage.addSubview(customBlurEffect)
    }

    // MARK: - Setup Comment Input View
    func setupCommentInputView() {
        commentContainerView.backgroundColor = UIColor(white: 0.1, alpha: 0.8)
        commentContainerView.layer.cornerRadius = 20
        commentContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        let commentIcon = UIImageView(image: UIImage(systemName: "bubble.left.and.bubble.right.fill"))
        commentIcon.tintColor = .white
        commentIcon.translatesAutoresizingMaskIntoConstraints = false
        
        commentTextField.backgroundColor = UIColor(white: 0.1, alpha: 0.9)
        commentTextField.textColor = .white
        commentTextField.attributedPlaceholder = NSAttributedString(string: "Add a comment...", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        commentTextField.translatesAutoresizingMaskIntoConstraints = false
            
        publishButton.backgroundColor = UIColor.green
        publishButton.layer.cornerRadius = 10
        publishButton.setTitleColor(.white, for: .normal)
        publishButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(commentContainerView)
        commentContainerView.addSubview(commentIcon)
        commentContainerView.addSubview(commentTextField)
        commentContainerView.addSubview(publishButton)
        
        // Contraintes Auto Layout
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
    
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        commentTextField.resignFirstResponder()
    }

    // MARK: - Functions
    @IBAction func publishButtonTapped(_ sender: Any) {
        if let text = commentTextField.text, !text.isEmpty {
            CommentService.shared.publishAComment(uid: Auth.auth().currentUser?.uid, comment: text, nameOfWriter: (Auth.auth().currentUser?.displayName)!, publicationID: publicationID)
            
            commentService.getComments(forPublicationID: publicationID) { comments in
                if comments.isEmpty {
                    print("No comments found for publicationID: \(self.publicationID)")
                } else {
                    self.comments = comments.map { comment in
                        UserComment(
                            nameOfWriter: comment.nameOfWriter,
                            commentText: comment.commentText
                        )
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        } else {
            presentAlert(title: "ERROR", message: "Please, add a comment before pressing the publish button")
        }
    }
    
    // MARK: - Alerts
    func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: AddCommentaryViewController.cellIdentifier, for: indexPath) as! CommentCell
        let comment = comments[indexPath.row]
        cell.configure(with: comment)
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
    let containerView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
        
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
        
        // Contraintes Auto Layout
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with comment: UserComment) {
        usernameLabel.text = comment.nameOfWriter
        commentLabel.text = comment.commentText
    }
}


extension AddCommentaryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
