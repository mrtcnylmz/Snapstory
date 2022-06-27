//
//  SearchPopUpViewController.swift
//  Snapstory Demo
//
//  Created by Mertcan Yılmaz
//

import UIKit
import Firebase

class SearchPopUpViewController: UIViewController {
    @IBOutlet weak var searchedUserProfilePicture: UIImageView!
    @IBOutlet weak var searchedUsername: UILabel!
    @IBOutlet weak var searchedUserEmail: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    var recievedData = [String: Any]()
    let firestore = Firestore.firestore()
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchedUserEmail.text = (recievedData["email"] as! String)
        searchedUsername.text = (recievedData["username"] as! String)
        let data = try? Data(contentsOf: URL(string: recievedData["profilePictureURL"] as! String)!)
        searchedUserProfilePicture.image = UIImage(data: data!)
    }
    
    //MARK: - followButonClicked
    @IBAction func followButonClicked(_ sender: Any) {
        firestore.collection("User_Infos").whereField("email", in: [UserSingleton.sharedUserInfo.userEmail]).getDocuments { querySnap, error in
            let docRef = querySnap?.documents.first?.reference
            if !((querySnap?.documents.first?.data()["following"] as! Array<String>).contains(self.recievedData["email"] as! String)){
                docRef!.updateData(["following" : FieldValue.arrayUnion([(self.recievedData["email"] as! String)])])
                docRef!.updateData(["numberOfFollowing" : (querySnap?.documents.first?.data()["numberOfFollowing"] as! Int) + 1])
                self.firestore.collection("User_Infos").whereField("email", in: [self.recievedData["email"] as! String]).getDocuments {snap, error in
                    let docRf = snap?.documents.first?.reference
                    self.followButton.isEnabled = false
                    self.followButton.configuration?.title = "Following"
                    docRf!.updateData(["followers" : FieldValue.arrayUnion([UserSingleton.sharedUserInfo.userEmail])])
                    docRf!.updateData(["numberOfFollowers" : (querySnap?.documents.first?.data()["numberOfFollowers"] as! Int) + 1])
                    UserSingleton.sharedUserInfo.following = querySnap?.documents.first?.data()["following"] as! Array<String>
                    AlertMaker().makeAlert(on: self, title: "Success", message: "You are now following \((self.recievedData["username"] as! String)).", okFunc: nil)
                    
                }
            }else{
                self.followButton.isEnabled = false
                self.followButton.configuration?.title = "Following"
                AlertMaker().makeAlert(on: self, title: "Error", message: "You already follow this user.", okFunc: nil)
            }
        }
    }
}
