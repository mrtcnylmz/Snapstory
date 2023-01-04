//
//  Picker.swift
//  Snapstory Demo
//
//  Created by Mertcan Yılmaz
//

import UIKit

@objcMembers class ImagePicker{
    @objc func promptPhoto(`on` controller: UIViewController) {
        let prompt = UIAlertController(title: "Choose a Photo", message: "Choose a photo for recognation.", preferredStyle: .actionSheet)
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = (controller as! UIImagePickerControllerDelegate & UINavigationControllerDelegate)
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: presentCamera)
        let libraryAction = UIAlertAction(title: "Photo Library", style: .default, handler: presentLibrary)
        //let albumsAction = UIAlertAction(title: "Saved Albums", style: .default, handler: presentAlbums)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        imagePicker.allowsEditing = true
        prompt.addAction(cameraAction)
        prompt.addAction(libraryAction)
        //prompt.addAction(albumsAction)
        prompt.addAction(cancelAction)
        controller.present(prompt, animated: true, completion: nil)

        func presentCamera(_ _: UIAlertAction) {
            imagePicker.sourceType = .camera
            controller.present(imagePicker, animated: true)
        }
        func presentLibrary(_ _: UIAlertAction) {
            imagePicker.sourceType = .photoLibrary
            controller.present(imagePicker, animated: true)
        }
//        func presentAlbums(_ _: UIAlertAction) {
//            imagePicker.sourceType = .savedPhotosAlbum
//            controller.present(imagePicker, animated: true)
//        }
    }
}
