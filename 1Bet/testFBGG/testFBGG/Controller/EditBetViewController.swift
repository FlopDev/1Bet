//
//  EditBetViewController.swift
//  testFBGG
//
//  Created by Florian Peyrony on 14/03/2023.
//


import UIKit
import FirebaseFirestore
import Firebase
import AVFoundation
import Photos

class EditBetViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Properties
    let shared = PublicationService()
    var numberOfPublish = 0
    let imagePicker = UIImagePickerController()
    var publicationID = ""
    
    // MARK: - Outlets
    @IBOutlet weak var addPictureButton: UIButton!
    @IBOutlet weak var dateOfTheBet: UITextField!
    @IBOutlet weak var imageViewOfTheBet: UIImageView!
    @IBOutlet weak var pronosticTextField: UITextField!
    @IBOutlet weak var trustOnTenTextField: UITextField!
    @IBOutlet weak var percentOfBkTextField: UITextField!
    @IBOutlet weak var basketBallImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        
        let customBlurEffect = CustomIntensityVisualEffectView(effect: UIBlurEffect(style: .regular), intensity: 0.00001)
        customBlurEffect.frame = basketBallImage.bounds
        customBlurEffect.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        basketBallImage.addSubview(customBlurEffect)
        
        PublicationService.shared.getLatestPublicationID { result in
            switch result {
            case .success(let documentID):
                print("ID de la dernière publication : \(documentID)")
                self.publicationID = documentID
            case .failure(let error):
                print("Erreur : \(error.localizedDescription)")
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Add tap gesture recognizers to the text fields
        addTapGestureToTextField(pronosticTextField)
        addTapGestureToTextField(trustOnTenTextField)
        addTapGestureToTextField(percentOfBkTextField)
    }
    
    private func addTapGestureToTextField(_ textField: UITextField) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.textFieldTapped(_:)))
        textField.addGestureRecognizer(tapGesture)
        textField.isUserInteractionEnabled = true
    }
    
    @objc func textFieldTapped(_ sender: UITapGestureRecognizer) {
        if let textField = sender.view as? UITextField {
            textField.becomeFirstResponder()
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let keyboardHeight = keyboardSize.height
        let activeTextField: UITextField?
        
        if pronosticTextField.isFirstResponder {
            activeTextField = pronosticTextField
        } else if percentOfBkTextField.isFirstResponder {
            activeTextField = percentOfBkTextField
        } else if trustOnTenTextField.isFirstResponder {
            activeTextField = trustOnTenTextField
        } else {
            activeTextField = nil
        }
        
        guard let textField = activeTextField else { return }
        
        let textFieldBottomY = textField.convert(textField.bounds, to: self.view).maxY
        let visibleAreaHeight = self.view.bounds.height - keyboardHeight
        
        if textFieldBottomY > visibleAreaHeight {
            self.view.frame.origin.y = -(textFieldBottomY - visibleAreaHeight + 10) // Adjust the 10 to your padding preference
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        self.view.frame.origin.y = 0
    }
    
    
    
    // MARK: - Other methods
    @IBAction func publishPronosticButton(_ sender: UIButton) {
        if dateOfTheBet.text == "" || pronosticTextField.text == "" || trustOnTenTextField.text == "" || percentOfBkTextField.text == "" || imageViewOfTheBet.image == nil {
            UIAlert.presentAlert(from: self, title: "ERROR", message: "Put some text in all the text entry before pressing publish button")
        } else {
            shared.savePublicationOnDB(date: dateOfTheBet.text!, description: pronosticTextField.text!, percentOfBankroll: percentOfBkTextField.text!, publicationID: publicationID, trustOnTen: trustOnTenTextField.text!)
            FirebaseStorageService.shared.uploadPhoto(image: imageViewOfTheBet.image!)
        }
        presentAlertAndAddAction(title: "Bet saved", message: "Your bet has been successfully saved, and will be published on OneBet soon")
    }
    
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func didPressAddPictureButton(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageViewOfTheBet.isHidden = false
            imageViewOfTheBet.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Alerts
    func presentAlertAndAddAction(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { action in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

extension EditBetViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
