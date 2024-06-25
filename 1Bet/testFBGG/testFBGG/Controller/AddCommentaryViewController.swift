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
    var comments: [Comment] = []
    let commentService = CommentService()
    var publicationID = ""
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var basketBallImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        PublicationService.shared.getLatestPublicationID { result in
            switch result {
            case .success(let documentID):
                print("ID de la dernière publication : \(documentID)")
                
                self.publicationID = documentID
                self.commentService.getComments(forPublicationID: self.publicationID) { comments in
                    if comments.isEmpty {
                        print("No comments found for publicationID: \(self.publicationID)")
                    } else {
                        for comment in comments {
                            print("Comment: \(comment.commentText)")
                            DispatchQueue.main.async {
                                self.comments = comments
                                self.tableView.reloadData()
                            }
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
    
    // MARK: - Functions
    @IBAction func publishButton(_ sender: Any) {
        if commentTextField.text != nil {
            CommentService.shared.publishAComment(uid: Auth.auth().currentUser?.uid, comment: commentTextField.text!, nameOfWriter: (Auth.auth().currentUser?.displayName)!, publicationID: publicationID)
            
            commentService.getComments(forPublicationID: publicationID) { comments in
                if comments.isEmpty {
                    print("No comments found for publicationID: \(self.publicationID)")
                } else {
                    for comment in comments {
                        print("Comment: \(comment.commentText)")
                        DispatchQueue.main.async {
                            self.comments = comments
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        } else {
            presentAlert(title: "ERROR", message: "Please, add a comment before press the publish button")
        }
        
    }
    
    // MARK: - Alerts
    func presentAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    // MARK: - Navigation
    
}

// MARK: - Extensions

extension AddCommentaryViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // le nombre de commentaires sur Firebase et non dans le commentary Service
        return comments.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AddCommentaryViewController.cellIdentifier, for: indexPath)
        //add the data of comments firebase in comments
        
        let comment = comments[indexPath.row]
        cell.textLabel?.text = comment.nameOfWriter
        cell.detailTextLabel?.text = comment.commentText
        print(comment.commentText)
        
        return cell
        
    }
}
