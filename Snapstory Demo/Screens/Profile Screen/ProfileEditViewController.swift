//
//  ProfileEditViewController.swift
//  Snapstory Demo
//
//  Created by Mertcan Yılmaz
//

import UIKit
import Firebase

class ProfileEditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var editImageView: UIImageView!
    @IBOutlet weak var editUsername: UITextField!
    @IBOutlet weak var UserEmail: UILabel!
    @IBOutlet weak var editUserBio: UITextView!
    
    var imageChanged = false
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editUsername.text = UserSingleton.shared.currentUser?.username
        editUserBio.text = UserSingleton.shared.currentUser?.userBio
        UserEmail.text = UserSingleton.shared.currentUser?.userEmail
        editImageView.image = UIImage(data: UserSingleton.shared.currentUser!.userProfilePictureData)
        editImageView.isUserInteractionEnabled = true
        let imagePickerTapRec = UITapGestureRecognizer(target: self, action: #selector(imagePicker))
        editImageView.addGestureRecognizer(imagePickerTapRec)
    }
    
    //MARK: - doneButtonClicked
    @IBAction func doneButtonClicked(_ sender: Any) {
        let changeRequest = auth.currentUser?.createProfileChangeRequest()
        guard editUsername.text!.count >= 3 else {
            self.basicAlert(title: "Error", message: "Username too short.")
            return
        }
        guard editUserBio.text!.count >= 1 else {
            self.basicAlert(title: "Error", message: "Bio too short.")
            return
        }
        
        changeRequest?.displayName = editUsername.text
        
        if imageChanged {
            let mediaFolder = storage.reference().child("media")
            if let data = editImageView.image?.jpegData(compressionQuality: 0.0){
                let uuid = UUID().uuidString
                let imageReferance = mediaFolder.child("\(uuid).jpg")
                imageReferance.putData(data, metadata: nil) { [weak self] storageMetadata, error in
                    guard error == nil else { return }
                    guard let self = self else { return }
                    imageReferance.downloadURL { url, error in
                        guard error == nil else { return }
                        changeRequest?.photoURL = url
                        changeRequest?.commitChanges { error in
                            guard error == nil else { return }
                            firestore.collection("Users").document(auth.currentUser!.uid).getDocument { DocShapshot, error in
                                guard error == nil else { return }
                                let userRef = DocShapshot?.reference
                                userRef!.updateData(["profilePictureURL" : url!.absoluteString])
                                userRef!.updateData(["bio" : self.editUserBio.text!])
                                userRef!.updateData(["username" : self.editUsername.text!])
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                    }
                }
            }
        }else{
            changeRequest?.commitChanges { [weak self] error in
                guard error == nil else { return }
                guard let self = self else { return }
                firestore.collection("Users").document(auth.currentUser!.uid).getDocument { DocShapshot, error in
                    guard error == nil else { return }
                    let userRef = DocShapshot?.reference
                    userRef!.updateData(["bio" : self.editUserBio.text!])
                    userRef!.updateData(["username" : self.editUsername.text!])
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    // MARK: - @objc imagePicker
    @objc func imagePicker(){
        ImagePicker().promptPhoto(on: self)
    }
    
    // MARK: - imagePickerController
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        editImageView.image = info[.editedImage] as? UIImage
        imageChanged = true
        self.dismiss(animated: true)
    }
}
