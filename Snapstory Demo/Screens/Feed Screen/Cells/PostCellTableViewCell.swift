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
    
    var postID = ""
    var postLiked = false {
        didSet {
            if postLiked{
                postLikeButton.setImage(UIImage(systemName: "heart.fill"), for: UIControl.State.normal)
            }else{
                postLikeButton.setImage(UIImage(systemName: "heart"), for: UIControl.State.normal)
            }
        }
    }
    var postLikes: Int = 0 {
        didSet {
            postLikeNumber.text = "\(postLikes) likes"
        }
    }
    
    // MARK: - awakeFromNib
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: - setSelected
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - 👍 postLikeButtonClicked
    @IBAction func postLikeButtonClicked(_ sender: Any) {
        let firebaseRef = firestore.collection("Posts").document(postID)
        firebaseRef.getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            guard error == nil else {
                fatalError("Network error.")
            }
            //let likes = (snapshot!.data()!["whoLiked"] as! [String]).count
            if self.postLiked{
                firebaseRef.updateData(["likes" : self.postLikes-1])
                self.postLikes -= 1
                //self.postLikeNumber.text = String(likes - 1) + " likes"
                firebaseRef.updateData(["whoLiked" : FieldValue.arrayRemove([auth.currentUser!.email!])])
                self.postLiked = false
                //self.postLikeButton.setImage(UIImage(systemName: "heart"), for: UIControl.State.normal)
            }else{
                firebaseRef.updateData(["likes" : self.postLikes+1])
                self.postLikes += 1
                //self.postLikeNumber.text = String(self.postLikes + 1) + " likes"
                firebaseRef.updateData(["whoLiked" : FieldValue.arrayUnion([auth.currentUser!.email!])])
                //firebaseRef.setData(["whoLiked" : [UserSingleton.sharedUserInfo.userEmail]], merge: true)
                self.postLiked = true
                //self.postLikeButton.setImage(UIImage(systemName: "heart.fill"), for: UIControl.State.normal)
            }
            
        }
    }
}
