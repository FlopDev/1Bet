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
    }
    
    // MARK: - Functions
    
    @IBAction func publishPronosticButton(_ sender: UIButton) {
        if dateOfTheBet.text == "" || pronosticTextField.text == "" || trustOnTenTextField.text == "" || percentOfBkTextField.text == "" || imageViewOfTheBet.image == nil {
            UIAlert.presentAlert(from: self, title: "ERROR", message: "Put some text in all the text entry before pressing publish button")
        } else {
            numberOfPublish += 1
            shared.savePublicationOnDB(date: dateOfTheBet.text!, description: pronosticTextField.text!, percentOfBankroll: percentOfBkTextField.text!, publicationID: numberOfPublish, trustOnTen: trustOnTenTextField.text!)
            FirebaseStorageService.shared.uploadPhoto(image: imageViewOfTheBet.image!) { error in
                guard let error = error else {
                    print("Erreur lors du téléchargement de l'image : \(error?.localizedDescription)")
                    UIAlert.presentAlert(from: self, title: "ERROR", message: "We cannot send the image on our Databse, check your connexion internet or contact the admin")
                    return
                }
            }
        }
        presentAlertAndAddAction(title: "Bet saved", message: "Your bet has been successfully saved, and will be published on OneBet soon")
    }
    
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        pronosticTextField.resignFirstResponder()
        trustOnTenTextField.resignFirstResponder()
        dateOfTheBet.resignFirstResponder()
        percentOfBkTextField.resignFirstResponder()
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
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        let okAction = UIAlertAction(title: "OK", style: .default) { action in
            // go back to the previous VC
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}


extension EditBetViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
