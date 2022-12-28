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
    
    let auth = Auth.auth()
    let firestore = Firestore.firestore()
    var imageChanged = false
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editUsername.text = UserSingleton.sharedUserInfo.username
        editUserBio.text = UserSingleton.sharedUserInfo.userBio
        UserEmail.text = UserSingleton.sharedUserInfo.userEmail
        editImageView.image = UserSingleton.sharedUserInfo.userProfilePicture
        editImageView.isUserInteractionEnabled = true
        let imagePickerTapRec = UITapGestureRecognizer(target: self, action: #selector(imagePicker))
        editImageView.addGestureRecognizer(imagePickerTapRec)
    }
    
    //MARK: - doneButtonClicked
    @IBAction func doneButtonClicked(_ sender: Any) {
        let changeRequest = auth.currentUser?.createProfileChangeRequest()
        if editUsername.text != nil{
            changeRequest?.displayName = editUsername.text
        }
        if imageChanged {
            let storage = Storage.storage()
            let storageReferance = storage.reference()
            let mediaFolder = storageReferance.child("media")
            if let data = editImageView.image?.jpegData(compressionQuality: 0.0){
                let uuid = UUID().uuidString
                let imageReferance = mediaFolder.child("\(uuid).jpg")
                imageReferance.putData(data, metadata: nil) { storageMetadata, error in
                    if error == nil{
                        imageReferance.downloadURL { url, error in
                            if error == nil{
                                changeRequest?.photoURL = url
                                changeRequest?.commitChanges { [self] error in
                                    if error == nil{
                                        firestore.collection("User_Infos").whereField("email", in: [UserSingleton.sharedUserInfo.userEmail]).getDocuments { [self] QuerySnapshot, Error in
                                            let ref = QuerySnapshot?.documents[0].reference
                                            ref?.updateData(["profilePictureURL" : url!.absoluteString])
                                            ref?.updateData(["bio" : editUserBio.text!])
                                            ref?.updateData(["username" : (self.auth.currentUser?.displayName ?? "no username")])
                                        }
                                        UserSingleton.sharedUserInfo.userProfilePictureURL = url!.absoluteString
                                        UserSingleton.sharedUserInfo.userProfilePicture = UIImage(data: data)
                                        UserSingleton.sharedUserInfo.userBio = editUserBio.text
                                        UserSingleton.sharedUserInfo.username = (self.auth.currentUser?.displayName ?? "no username")
                                        navigationController?.popViewController(animated: true)
                                    }
                                    else {
                                        self.basicAlert(title: "Error", message: error!.localizedDescription)
                                    }
                                }
                            }else {
                                self.basicAlert(title: "Error", message: error!.localizedDescription)
                            }
                        }
                    }else {
                        self.basicAlert(title: "Error", message: error!.localizedDescription)
                    }
                }
            }
        }else{
            changeRequest?.commitChanges { [self] error in
                if error == nil{
                    firestore.collection("User_Infos").whereField("email", in: [UserSingleton.sharedUserInfo.userEmail]).getDocuments { [self] QuerySnapshot, Error in
                        let ref = QuerySnapshot?.documents[0].reference
                        ref?.updateData(["bio" : editUserBio.text!])
                        ref?.updateData(["username" : (self.auth.currentUser?.displayName ?? "no username")])
                    }
                    UserSingleton.sharedUserInfo.username = (self.auth.currentUser?.displayName ?? "no username")
                    UserSingleton.sharedUserInfo.userBio = self.editUserBio.text
                    navigationController?.popViewController(animated: true)
                }else {
                    self.basicAlert(title: "Error", message: error!.localizedDescription)
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
