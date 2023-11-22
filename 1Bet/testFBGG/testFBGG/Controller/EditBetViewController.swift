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
        if dateOfTheBet.text == "" || pronosticTextField.text == "" || trustOnTenTextField.text == "" || percentOfBkTextField.text == "" {
            presentAlert(title: "Missing Text Entry", message: "Put some text in all the text entry after press publish button")
        } else {
            numberOfPublish += 1
            shared.savePublicationOnDB(date: dateOfTheBet.text!, description: pronosticTextField.text!, percentOfBankroll: percentOfBkTextField.text!, publicationID: numberOfPublish, trustOnTen: trustOnTenTextField.text!)
            
            
        }
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
    func presentAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}
