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
import UserNotifications

class EditBetViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Properties
    private let shared = PublicationService()              // Service to handle publications
    private let imagePicker = UIImagePickerController()    // Image picker for selecting a photo
    private var publicationID = ""                         // Stores the current publication ID
    
    // MARK: - Outlets
    @IBOutlet weak var addPictureButton: UIButton!
    @IBOutlet weak var dateOfTheBet: UITextField!
    @IBOutlet weak var imageViewOfTheBet: UIImageView!
    @IBOutlet weak var pronosticTextView: UITextView!
    @IBOutlet weak var trustOnTenTextField: UITextField!
    @IBOutlet weak var percentOfBkTextField: UITextField!
    @IBOutlet weak var basketBallImage: UIImageView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImagePicker()           // Configure image picker settings
        configureBlurEffect()        // Add blur effect on background image
        fetchLatestPublicationID()   // Fetch the latest publication ID
        setupKeyboardObservers()     // Initialize keyboard observers
        configureTextInputTapGesture() // Add tap gestures to text fields
    }

    // MARK: - Setup Methods
    
    /// Configures the image picker for selecting photos.
    private func setupImagePicker() {
        imagePicker.delegate = self
    }
    
    /// Adds a blur effect to the background image.
    private func configureBlurEffect() {
        let customBlurEffect = CustomIntensityVisualEffectView(effect: UIBlurEffect(style: .regular), intensity: 0.00001)
        customBlurEffect.frame = basketBallImage.bounds
        customBlurEffect.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        basketBallImage.addSubview(customBlurEffect)
    }
    
    /// Retrieves the latest publication ID for further operations.
    private func fetchLatestPublicationID() {
        PublicationService.shared.getLatestPublicationID { result in
            switch result {
            case .success(let documentID):
                self.publicationID = documentID
            case .failure(let error):
                print("Error fetching publication ID: \(error.localizedDescription)")
            }
        }
    }
    
    /// Sets up observers to adjust the view when the keyboard appears or disappears.
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    /// Adds tap gestures to text inputs to enable the keyboard when tapped.
    private func configureTextInputTapGesture() {
        [pronosticTextView, trustOnTenTextField, percentOfBkTextField].forEach { addTapGestureToTextInput($0) }
    }
    
    /// Adds a tap gesture recognizer to activate the text field or text view.
    private func addTapGestureToTextInput(_ view: UIView) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(textInputTapped(_:)))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
    }
    
    @objc private func textInputTapped(_ sender: UITapGestureRecognizer) {
        if let textField = sender.view as? UITextField {
            textField.becomeFirstResponder()
        } else if let textView = sender.view as? UITextView {
            textView.becomeFirstResponder()
        }
    }
    
    // MARK: - Keyboard Handling
    
    /// Moves the view up if the keyboard hides an active input field.
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        adjustViewForKeyboard(keyboardHeight: keyboardSize.height)
    }
    
    /// Resets the view position when the keyboard hides.
    @objc private func keyboardWillHide(_ notification: Notification) {
        resetViewPosition()
    }
    
    /// Adjusts the view position to prevent the keyboard from hiding the active input field.
    private func adjustViewForKeyboard(keyboardHeight: CGFloat) {
        guard let activeInput = [pronosticTextView, percentOfBkTextField, trustOnTenTextField].first(where: { $0.isFirstResponder }),
              let inputViewBottomY = activeInput.superview?.convert(activeInput.frame, to: self.view).maxY else { return }

        let visibleAreaHeight = self.view.bounds.height - keyboardHeight
        if inputViewBottomY > visibleAreaHeight {
            self.view.frame.origin.y = -(inputViewBottomY - visibleAreaHeight + 60) // Adjusted offset
        }
    }
    
    /// Resets the view position to its original state.
    private func resetViewPosition() {
        self.view.frame.origin.y = 0
    }
    
    // MARK: - Actions
    
    /// Validates and publishes the bet when the publish button is tapped.
    @IBAction private func publishPronosticButtonTapped(_ sender: UIButton) {
        guard areInputsValid() else {
            showErrorAlert(message: "Fill in all fields before publishing")
            return
        }
        savePublication()  // Saves publication details in the database
        uploadImage()      // Uploads the associated image
        sendNotification() // Sends a notification
        showConfirmationAlert()  // Shows confirmation alert after saving
    }
    
    /// Checks if all required input fields have data before publishing.
    private func areInputsValid() -> Bool {
        return !(dateOfTheBet.text?.isEmpty ?? true ||
                 pronosticTextView.text.isEmpty ||
                 trustOnTenTextField.text?.isEmpty ?? true ||
                 percentOfBkTextField.text?.isEmpty ?? true ||
                 imageViewOfTheBet.image == nil)
    }
    
    /// Saves the bet information to the database.
    private func savePublication() {
        shared.savePublicationOnDB(
            date: dateOfTheBet.text!,
            description: pronosticTextView.text!,
            percentOfBankroll: percentOfBkTextField.text!,
            publicationID: publicationID,
            trustOnTen: trustOnTenTextField.text!
        )
    }
    
    /// Uploads the selected image to Firebase.
    private func uploadImage() {
        if let image = imageViewOfTheBet.image {
            FirebaseStorageService.shared.uploadPhoto(image: image)
        }
    }
    
    /// Dismisses the keyboard when tapping outside input fields.
    @IBAction private func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    /// Opens the photo library to select an image.
    @IBAction private func didPressAddPictureButton(_ sender: UIButton) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - Image Picker Delegate Methods
    
    /// Sets the selected image from the photo library to the imageView.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            imageViewOfTheBet.isHidden = false
            imageViewOfTheBet.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
    /// Cancels the image selection if the user chooses.
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Alerts
    
    /// Displays a confirmation alert after saving, and navigates to the main page.
    private func showConfirmationAlert() {
        let alert = UIAlertController(title: "Bet Saved", message: "Your bet has been saved and will be published soon.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.navigateToMainPage()
        })
        present(alert, animated: true, completion: nil)
    }
    
    /// Shows an error alert with a custom message if validation fails.
    private func showErrorAlert(message: String) {
        UIAlert.presentAlert(from: self, title: "Error", message: message)
    }
    
    /// Navigates to the main page after successful bet saving.
    private func navigateToMainPage() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let mainPageVC = storyboard.instantiateViewController(withIdentifier: "MainPageViewController") as? MainPageViewController {
            mainPageVC.modalPresentationStyle = .fullScreen
            present(mainPageVC, animated: true, completion: nil)
        }
    }
    
    /// Removes keyboard observers when the view disappears.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Notification

/// Sends a notification to inform the user about a new bet being available.
func sendNotification() {
    let content = UNMutableNotificationContent()
    content.title = "New Pronostic Available!"
    content.body = "Check out the latest pronostic now."
    content.sound = .default

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("Error adding notification request: \(error)")
        }
    }
}

// MARK: - UITextFieldDelegate

extension EditBetViewController: UITextFieldDelegate {
    
    /// Dismisses the keyboard when the return key is pressed.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
