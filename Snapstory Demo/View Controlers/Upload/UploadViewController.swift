//
//  UploadViewController.swift
//  Snapstory Demo
//
//  Created by Mertcan Yılmaz
//

import UIKit
import SwiftUI
import MapKit
import CoreLocation
import Firebase
import FirebaseStorage

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate{
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var addLocationButton: UIButton!
    @IBOutlet weak var userProfilePictureImageView: UIImageView!
    
    let firestore = Firestore.firestore()
    var locationName = ""
    var locationCoordinates : CLLocationDegrees?
    var hasDescription = false
    var imagePicked = false

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "New Post"
        imageView.isUserInteractionEnabled = true
        ImagePicker().promptPhoto(on: self)
        descriptionTextView.delegate = self
        descriptionTextView.text = "Describe your post."
        descriptionTextView.textColor = UIColor.lightGray
        userProfilePictureImageView.image = UserSingleton.sharedUserInfo.userProfilePicture
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: UIBarButtonItem.Style.done, target: self, action: #selector(shareButtonClicked))
        let hideKeyboardTapRec = UITapGestureRecognizer(target: self, action: #selector(hideKeyb))
        view.addGestureRecognizer(hideKeyboardTapRec)
        let imagePickerTapRec = UITapGestureRecognizer(target: self, action: #selector(imagePicker))
        imageView.addGestureRecognizer(imagePickerTapRec)
    }
    
    // MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getLocationData), name: NSNotification.Name(rawValue: "locationData"), object: nil)
    }
    
    // MARK: - textViewDidBeginEditing
    func textViewDidBeginEditing(_ textView: UITextView) {
        hasDescription = false
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    // MARK: - textViewDidEndEditing
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            hasDescription = false
            textView.text = "Describe your post."
            textView.textColor = UIColor.lightGray
        }else{
            hasDescription = true
        }
    }
    
    // MARK: - imagePickerController
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.editedImage] as? UIImage
        imagePicked = true
        self.dismiss(animated: true)
    }

    // MARK: - hideKeyb
    @objc func hideKeyb(){
        view.endEditing(true)
    }

    // MARK: - @objc imagePicker
    @objc func imagePicker(){
        ImagePicker().promptPhoto(on: self)
    }

    //MARK: - getLocationData
    @objc func getLocationData(){
        locationName = (UserDefaults.standard.object(forKey: "locationString") as! String)
        locationCoordinates = (UserDefaults.standard.object(forKey: "locationCoordinateLongitude") as! CLLocationDegrees)
        addLocationButton.configuration?.title = "📍 " + locationName
    }
    
    //MARK: - shareButtonClicked
    @objc func shareButtonClicked(){
        hideKeyb()
        if !hasDescription || !imagePicked{
            if !imagePicked{
                AlertMaker().makeAlert(on: self, title: "⚠️", message: "Please pick a picture for your post.", okFunc: nil)
            }else{
                AlertMaker().makeAlert(on: self, title: "⚠️", message: "Please type a description for your post.", okFunc: nil)
            }
        }else{
            let storage = Storage.storage()
            let storageReferance = storage.reference()
            let mediaFolder = storageReferance.child("media")
            
            if let data = imageView.image?.jpegData(compressionQuality: 0.0){
                let uuid = UUID().uuidString
                let imageReferance = mediaFolder.child("\(uuid).jpg")
                imageReferance.putData(data, metadata: nil) { storageMetadata, error in
                    if error == nil{
                        imageReferance.downloadURL { url, error in
                            if error == nil{
                                let imageUrl = url?.absoluteString
                                let firestore = Firestore.firestore()
                                let postDictionary = [
                                    "imageURL": imageUrl!,
                                    "imageName": "\(uuid).jpg",
                                    "imageDescription": self.descriptionTextView.text!,
                                    "postOwnerEmail": UserSingleton.sharedUserInfo.userEmail,
                                    "date": FieldValue.serverTimestamp(),
                                    "likes": 0,
                                    "postLocation": self.locationName,
                                    "whoLiked": []
                                ] as [String: Any]
                                firestore.collection("Posts").addDocument(data: postDictionary) { error in
                                    if error != nil{
                                        AlertMaker().makeAlert(on: self, title: "Error", message: error!.localizedDescription, okFunc: nil)
                                    }else{
                                        AlertMaker().makeAlert(on: self, title: "Done", message: "Successfully Shared!", okFunc: nil)
                                        firestore.collection("User_Infos").whereField("email", in: [UserSingleton.sharedUserInfo.userEmail]).getDocuments { snap, error in
                                            snap!.documents.first?.reference.updateData(["numberOfPosts" : (snap!.documents.first?.data()["numberOfPosts"] as! Int) + 1])
                                        }
                                        self.imageView.image = UIImage(systemName: "camera.viewfinder")
                                        self.locationName = ""
                                        self.addLocationButton.configuration?.title = "📍 Add Location"
                                        self.descriptionTextView.text = "Describe your post."
                                        self.descriptionTextView.textColor = UIColor.lightGray
                                        self.hasDescription = false
                                        self.imagePicked = false
                                        self.tabBarController?.selectedIndex = 0
                                    }
                                }
                            }
                        }
                    }else {
                        AlertMaker().makeAlert(on: self, title: "Error", message: error!.localizedDescription, okFunc: nil)
                    }
                }
            }
        }
    }
    
    //MARK: - resetLocationDataButtonClicked
    @IBAction func resetLocationDataButtonClicked(_ sender: Any) {
        self.locationName = ""
        self.addLocationButton.configuration?.title = "📍 Add Location"
    }
}
