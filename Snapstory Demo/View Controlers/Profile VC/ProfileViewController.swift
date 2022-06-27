//
//  ProfileViewController.swift
//  Snapstory Demo
//
//  Created by Mertcan Yılmaz
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileUsernameLabel: UILabel!
    @IBOutlet weak var profileUserEmailLabel: UILabel!
    @IBOutlet weak var profileUserPostNumberLabel: UILabel!
    @IBOutlet weak var profileUserFollowerNumberLabel: UILabel!
    @IBOutlet weak var profileUserFollowingNumberLabel: UILabel!
    @IBOutlet weak var profileUserBio: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = UserSingleton.sharedUserInfo.username
        profileUsernameLabel.text = UserSingleton.sharedUserInfo.username
        profileUserEmailLabel.text = UserSingleton.sharedUserInfo.userEmail
        profileImageView.image = UserSingleton.sharedUserInfo.userProfilePicture
        profileUserBio.text = UserSingleton.sharedUserInfo.userBio
        profileUserPostNumberLabel.text = String(UserSingleton.sharedUserInfo.postNumber)
        profileUserFollowerNumberLabel.text = String(UserSingleton.sharedUserInfo.followerNumber)
        profileUserFollowingNumberLabel.text = String(UserSingleton.sharedUserInfo.followingNumber)
    }
}
