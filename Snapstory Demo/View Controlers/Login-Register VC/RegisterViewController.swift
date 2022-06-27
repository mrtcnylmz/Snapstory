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
    
    // MARK: - doneButton
    @IBAction func doneButton(_ sender: Any) {
        userAuth.createUser(withEmail: registerEmail.text!, password: registerPassword.text!) { [self] AuthResult, error in
            if error != nil{
                AlertMaker().makeAlert(on: self, title: "⚠️ Error", message: error!.localizedDescription, okFunc: nil)
            }else{
                let changeRequest = userAuth.currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = registerUsername.text
                changeRequest?.photoURL = URL(string: "https://firebasestorage.googleapis.com/v0/b/snapstory-1fcce.appspot.com/o/media%2F360_F_64676383_LdbmhiNM6Ypzb3FM4PPuFP9rHe7ri8Ju.jpeg?alt=media&token=bd694d5e-c524-4142-8df6-b31f00d25c20")
                changeRequest?.commitChanges { error in
                  // ...
                }
                let userInfoDictionary = [
                    "email": registerEmail.text!,
                    "username": registerUsername.text!,
                    "bio": "",
                    "profilePictureURL": "https://firebasestorage.googleapis.com/v0/b/snapstory-1fcce.appspot.com/o/media%2F360_F_64676383_LdbmhiNM6Ypzb3FM4PPuFP9rHe7ri8Ju.jpeg?alt=media&token=bd694d5e-c524-4142-8df6-b31f00d25c20",
                    "numberOfPosts": 0,
                    "numberOfFollowers": 0,
                    "numberOfFollowing": 0,
                    "following": [],
                    "followers": [],
                    "posts": []
                    ]as [String: Any]
                fireStore.collection("User_Infos").addDocument(data: userInfoDictionary){(error) in
                    if error != nil{
                        //AlertMaker().makeAlert(on: self, title: "Error", message: error!.localizedDescription, okFunc: nil)
                    }
                }
                AlertMaker().makeAlert(on: self, title: "Success", message: "User created!", okFunc: {_ in
                    self.performSegue(withIdentifier: "toTabBar", sender: nil)
                })
            }
        }
    }
}
