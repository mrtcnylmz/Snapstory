//
//  LoginViewController.swift
//  Snapstory Demo
//
//  Created by Mertcan Yılmaz
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class LoginViewController: UIViewController {
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    
    let firestore = Firestore.firestore()
    let auth = Auth.auth()
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    
    // MARK: - loginButton
    @IBAction func loginButton(_ sender: Any) {
        Firebase().signIn(controller: self, email: userEmail.text!, password: userPassword.text!)
//        self.showIndicationSpinner()
//        Auth.auth().signIn(withEmail: userEmail.text!, password: userPassword.text!) { [weak self] authResult, err in
//            guard let self = self else { return }
//            self.removeIndicationSpinner()
//            guard err == nil else {
//                self.basicAlert(title: "⚠️ Error", message: err!.localizedDescription )
//                return
//            }
//            guard Auth.auth().currentUser != nil else {
//                self.basicAlert(title: "⚠️ Error", message: "Error.")
//                return
//            }
//            self.performSegue(withIdentifier: "toTabBar", sender: nil)
//        }
    }
    
    //MARK: - getUserInfo
    func getUserInfo(userId: String, completion: @escaping (_ user: User) -> Void) {
        
    }
    
    // MARK: - forgotPasswordButton
    @IBAction func forgotPasswordButton(_ sender: Any) {
        let alert = UIAlertController(title: "🐟 Password Reset", message: "Please input you email.", preferredStyle: .alert)
        alert.addTextField { UITextField in UITextField.placeholder = "User Email" }
        let okAction = UIAlertAction(title: "Ok", style: .default) { _ in
            guard alert.textFields![0].text!.count >= 6 else {
                self.basicAlert(title: "⚠️ Error", message: "A valid email address must be provided.")
                return
            }
            Firebase().resetPassword(controller: self,email: alert.textFields![0].text!)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.present(alert, animated: true)
    }
    
    //MARK: - gerUserInfo
    func getUserInfo(id: String, complation: @escaping (_ user: User) -> Void) {
        let docRef = firestore.collection("User_Infos").document(id)
        docRef.getDocument { document, error in
            guard error == nil, let document = document else {
                self.basicAlert(title: "Error", message: "Network error.")
                return
            }
            guard document.exists else {
                self.basicAlert(title: "Error", message: "Not a valid ID.")
                return
            }
            
            let id = document.documentID
            let data = document.data()
            
            let username = data?["username"] as? String ?? ""
            let userEmail = data?["email"] as? String ?? ""
            let userBio = data?["bio"] as? String ?? ""
            let postNumber = data?["numberOfPosts"] as! Int
            let followerNumber = data?["numberOfFollowers"] as! Int
            let followingNumber = data?["numberOfFollowing"] as! Int
            let userProfilePictureURL = data?["profilePictureURL"] as! String
            let userProfilePictureData = try? Data(contentsOf: URL(string: userProfilePictureURL)!)
            let followers = data?["followers"] as! Array<String>
            let following = data?["following"] as! Array<String>
            
            let user = User(id: id,
                            username: username,
                            userEmail: userEmail,
                            userBio: userBio,
                            postNumber: postNumber,
                            followerNumber: followerNumber,
                            followingNumber: followingNumber,
                            userProfilePictureData: userProfilePictureData!,
                            userProfilePictureURL: userProfilePictureURL,
                            followers: followers,
                            following: following)
            complation(user)
        }
    }
}
