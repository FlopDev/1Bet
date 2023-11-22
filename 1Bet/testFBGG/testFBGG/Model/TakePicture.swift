//
//  TakePicture.swift
//  testFBGG
//
//  Created by Florian Peyrony on 18/04/2023.
//

import Foundation
import UIKit
import UniformTypeIdentifiers

class TakePicture {

    func takePhotoOrChooseFromLibrary(controller: UIViewController, source: UIImagePickerController.SourceType, destinationUrl: URL) {
        // Create a new UIImagePickerController
        let picker = UIImagePickerController()
        
        // Set the source of the image picker
        picker.sourceType = source
        
        // Set the media types to images only
        picker.mediaTypes = [UTType.image.identifier]
        
        // Disable editing
        picker.allowsEditing = false
        
        // Set the delegate to the view controller that called this function
        picker.delegate = controller as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        
        // If the source is the camera, set the capture mode to photo
        if source == .camera {
            picker.cameraCaptureMode = .photo
        }
        
        // Present the image picker to the user
        controller.present(picker, animated: true, completion: nil)
        
        // When the user chooses to save the image
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { alert in
            // Code à exécuter lorsque l'utilisateur appuie sur le bouton "Save"
            // Get the image from the image view
            if let image = picker.imageView?.image {
                // Convert the image to JPEG data
                if let imageData = image.jpegData(compressionQuality: 1.0) {
                    // Write the data to the destination URL
                    try? imageData.write(to: destinationUrl)
                }
            }
        }
        
        // When the user chooses to cancel
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { alert in
            // Dismiss the image picker
            picker.dismiss(animated: true, completion: nil)
        }
        
        // Show an alert with save and cancel actions
        let alert = UIAlertController(title: "Save Image", message: nil, preferredStyle: .alert)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        controller.present(alert, animated: true, completion: nil)
    }
}
