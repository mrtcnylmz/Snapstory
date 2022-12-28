//
//  PostCellTableViewCell.swift
//  Snapstory Demo
//
//  Created by Mertcan Yılmaz
//

import UIKit
import Firebase

class PostCellTableViewCell: UITableViewCell {
    @IBOutlet weak var postProfilePicture: UIImageView!
    @IBOutlet weak var postUsername: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postLikeNumber: UILabel!
    @IBOutlet weak var postDescription: UITextView!
    @IBOutlet weak var postLocation: UILabel!
    @IBOutlet weak var postLikeButton: UIButton!
    @IBOutlet weak var postUserEmail: UILabel!
    @IBOutlet weak var postDate: UILabel!
    
    let firestore = Firestore.firestore()
    var postID = ""
    var postLiked = false
    
    // MARK: - awakeFromNib
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // MARK: - setSelected
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if postLiked{
            postLikeButton.setImage(UIImage(systemName: "heart.fill"), for: UIControl.State.normal)
        }else{
            postLikeButton.setImage(UIImage(systemName: "heart"), for: UIControl.State.normal)
        }
    }
    
    // MARK: - 👍 postLikeButtonClicked
    @IBAction func postLikeButtonClicked(_ sender: Any) {
        let firebaseRef = firestore.collection("Posts").document(postID)
        firebaseRef.getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            if error == nil{
                let likes = (snapshot?.data()!["whoLiked"] as! [String]).count
                if self.postLiked{
                    firebaseRef.updateData(["likes" : likes-1])
                    self.postLikeNumber.text = String(likes - 1) + " likes"
                    firebaseRef.updateData(["whoLiked" : FieldValue.arrayRemove([UserSingleton.sharedUserInfo.userEmail])])
                    self.postLiked = false
                    self.postLikeButton.setImage(UIImage(systemName: "heart"), for: UIControl.State.normal)
                }else{
                    firebaseRef.updateData(["likes" : likes+1])
                    self.postLikeNumber.text = String(likes + 1) + " likes"
                    firebaseRef.updateData(["whoLiked" : FieldValue.arrayUnion([UserSingleton.sharedUserInfo.userEmail])])
                    //firebaseRef.setData(["whoLiked" : [UserSingleton.sharedUserInfo.userEmail]], merge: true)
                    self.postLiked = true
                    self.postLikeButton.setImage(UIImage(systemName: "heart.fill"), for: UIControl.State.normal)
                }
            }
        }
    }
}
