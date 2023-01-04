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
    @IBOutlet weak var popoutView: UIView!
    
    var recievedData: QueryDocumentSnapshot?
    var userFollowingList = [String]()
    let firestore = Firestore.firestore()
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popoutView.layer.cornerRadius = CGFloat(15)
        searchedUserProfilePicture.layer.cornerRadius = CGFloat(15)
        
        searchedUserEmail.text = (recievedData?.data()["email"] as! String)
        searchedUsername.text = (recievedData?.data()["username"] as! String)
        let data = try? Data(contentsOf: URL(string: recievedData?.data()["profilePictureURL"] as! String)!)
        searchedUserProfilePicture.image = UIImage(data: data!)
    }
    
    //MARK: - followButonClicked
    @IBAction func followButonClicked(_ sender: Any) {
        firestore.collection("Users").whereField("email", in: [auth.currentUser!.email!]).getDocuments { querySnap, error in
            guard error == nil else { return }
            let currentUserRef = querySnap?.documents.first?.reference
            currentUserRef!.updateData(["following" : FieldValue.arrayUnion([(self.recievedData!.documentID)])])
            currentUserRef!.updateData(["numberOfFollowing" : (querySnap?.documents.first?.data()["numberOfFollowing"] as! Int) + 1])
            
            self.firestore.collection("Users").whereField("email", in: [self.recievedData?.data()["email"] as! String]).getDocuments { snap, error in
                guard error == nil else { return }
                let docRf = snap?.documents.first?.reference
                docRf!.updateData(["followers" : FieldValue.arrayUnion([auth.currentUser!.uid])])
                docRf!.updateData(["numberOfFollowers" : (querySnap?.documents.first?.data()["numberOfFollowers"] as! Int) + 1])
                self.followButton.isEnabled = false
                self.followButton.configuration?.title = "Following"
                self.basicAlert(title: "Success", message: "You are now following \((self.recievedData?.data()["username"] as! String)).")
                
            }
        }
    }
}
