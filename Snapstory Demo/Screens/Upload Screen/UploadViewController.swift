//
//  UploadViewController.swift
//  Snapstory Demo
//
//  Created by Mertcan Yılmaz
//
// //TODO: Download user picture beforehand

import UIKit
import SwiftUI
import MapKit
import CoreLocation
import Firebase
import FirebaseStorage

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, PostLocationDelegate{
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var addLocationButton: UIButton!
    @IBOutlet weak var userProfilePictureImageView: UIImageView!
    
    var locationName = "" {
        didSet {
            addLocationButton.configuration?.title = "📍 " + (locationName.isEmpty ? "Add Location" : locationName)
        }
    }
    
    var hasDescription = false
    var imagePicked = false
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dismissKeyboardWhenTapped()
        
        navigationItem.title = "New Post"
        
        userProfilePictureImageView.layer.cornerRadius = 10.0
        userProfilePictureImageView.layer.borderWidth = 0.1
        imageView.layer.cornerRadius = 10.0
        imageView.layer.borderWidth = 0.1
        descriptionTextView.layer.cornerRadius = 10.0
        descriptionTextView.layer.borderWidth = 0.1
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imagePicker)))
        
        descriptionTextView.delegate = self
        descriptionTextView.text = "Describe your post."
        descriptionTextView.textColor = UIColor.lightGray
        
        userProfilePictureImageView.downloadImage(from: auth.currentUser!.photoURL)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .done, target: self, action: #selector(shareButtonClicked))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        ImagePicker().promptPhoto(on: self)
    }
    
    // MARK: - textViewDidBeginEditing
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard hasDescription else {
            textView.text = nil
            textView.textColor = UIColor.black
            return
        }
        hasDescription = false
    }
    
    // MARK: - textViewDidEndEditing
    func textViewDidEndEditing(_ textView: UITextView) {
        guard !textView.text.isEmpty else {
            hasDescription = false
            textView.text = "Describe your post."
            textView.textColor = UIColor.lightGray
            return
        }
        hasDescription = true
    }
    
    // MARK: - imagePickerController
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.editedImage] as? UIImage
        imagePicked = true
        self.dismiss(animated: true)
    }
    
    // MARK: - @objc imagePicker
    @objc func imagePicker(){
        ImagePicker().promptPhoto(on: self)
    }
    
    func location(locationName: String) {
        self.locationName = locationName
    }
    
    //MARK: - shareButtonClicked
    @objc func shareButtonClicked(){
        view.endEditing(true)
        guard hasDescription, imagePicked else {
            self.basicAlert(title: "⚠️", message: (!imagePicked ?
                                                   "Please pick a picture for your post." :
                                                    "Please type a description for your post."))
            return
        }
        let mediaFolder = storage.reference().child("media")
        if let data = imageView.image?.jpegData(compressionQuality: 0.0){
            let uuid = UUID().uuidString
            let imageReferance = mediaFolder.child("\(uuid).jpg")
            imageReferance.putData(data, metadata: nil) { [weak self] storageMetadata, error in
                guard let self = self else { return }
                guard error == nil else {
                    self.basicAlert(title: "Error", message: error!.localizedDescription)
                    return
                }
                imageReferance.downloadURL { url, error in
                    guard error == nil else {
                        self.basicAlert(title: "Error", message: error!.localizedDescription)
                        return
                    }
                    let postDictionary = [
                        "imageURL": url!.absoluteString,
                        "imageName": "\(uuid).jpg",
                        "imageDescription": self.descriptionTextView.text!,
                        "postOwnerEmail": auth.currentUser!.email!,
                        "postOwnerId": auth.currentUser!.uid,
                        "date": FieldValue.serverTimestamp(),
                        "likes": 0,
                        "postLocation": self.locationName,
                        "whoLiked": []
                    ] as [String: Any]
                    
                    firestore.collection("Posts").addDocument(data: postDictionary) { error in
                        guard error == nil else {
                            self.basicAlert(title: "Error", message: error!.localizedDescription)
                            return
                        }
                        self.basicAlert(title: "Done", message: "Successfully Shared!")
                        firestore.collection("Users").document(auth.currentUser!.uid).getDocument { snapshot, error in
                            snapshot!.reference.updateData(["numberOfPosts" : (snapshot!.data()!["numberOfPosts"] as! Int) + 1])
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
    }
    
    //MARK: - resetLocationDataButtonClicked
    @IBAction func resetLocationDataButtonClicked(_ sender: Any) {
        self.locationName = ""
    }
    
    @IBAction func addLocationButtonAction(_ sender: Any) {
        let mapView = self.storyboard!.instantiateViewController(identifier: "mapView") as! PostLocationViewController
        mapView.delegate = self
        self.present(mapView, animated: true)
    }
}
