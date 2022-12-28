//
//  RegisterViewController.swift
//  Snapstory Demo
//
//  Created by Mertcan Yılmaz
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    @IBOutlet weak var registerEmail: UITextField!
    @IBOutlet weak var registerUsername: UITextField!
    @IBOutlet weak var registerPassword: UITextField!
    
    let userAuth = Auth.auth()
    let fireStore = Firestore.firestore()
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    // MARK: - doneButton
    @IBAction func doneButton(_ sender: Any) {
        self.showIndicationSpinner()
        guard registerUsername.text!.count >= 3 else {
            self.removeIndicationSpinner()
            self.basicAlert(title: "Error", message: "Username too short.")
            return
        }
        userAuth.createUser(withEmail: registerEmail.text!, password: registerPassword.text!) { [weak self] AuthResult, error in
            guard let self = self else { return }
            self.removeIndicationSpinner()
            guard error == nil else {
                self.basicAlert(title: "⚠️ Error", message: error!.localizedDescription)
                return
            }
            
            let changeRequest = self.userAuth.currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = self.registerUsername.text
            let defaultPhotoUrl = URL(string: "https://firebasestorage.googleapis.com/v0/b/snapstory-1fcce.appspot.com/o/media%2F360_F_64676383_LdbmhiNM6Ypzb3FM4PPuFP9rHe7ri8Ju.jpeg?alt=media&token=bd694d5e-c524-4142-8df6-b31f00d25c20")
            changeRequest?.photoURL = defaultPhotoUrl
            changeRequest?.commitChanges { error in
                self.basicAlert(title: "Error", message: "An error occured.")
            }
            let userInfoDictionary = [
                "email": self.registerEmail.text!,
                "username": self.registerUsername.text!,
                "bio": "",
                "profilePictureURL": "https://firebasestorage.googleapis.com/v0/b/snapstory-1fcce.appspot.com/o/media%2F360_F_64676383_LdbmhiNM6Ypzb3FM4PPuFP9rHe7ri8Ju.jpeg?alt=media&token=bd694d5e-c524-4142-8df6-b31f00d25c20",
                "numberOfPosts": 0,
                "numberOfFollowers": 0,
                "numberOfFollowing": 0,
                "following": [],
                "followers": [],
                "posts": []
            ]as [String: Any]
            self.fireStore.collection("User_Infos").addDocument(data: userInfoDictionary){(error) in
                guard error == nil else {
                    self.basicAlert(title: "Error", message: "An error occured while signing in. \(String(describing: error?.localizedDescription))")
                    return
                }
            }
            self.basicAlert(title: "Success", message: "User created!", buttonAction: {_ in
                self.performSegue(withIdentifier: "toTabBar", sender: nil)
            })
        }
    }
}
