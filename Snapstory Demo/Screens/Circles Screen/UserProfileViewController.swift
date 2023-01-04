//
//  UserProfileViewController.swift
//  Snapstory Demo
//
//  Created by Mertcan Yılmaz on 4.01.2023.
//

import UIKit

class UserProfileViewController: UIViewController {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileUsernameLabel: UILabel!
    @IBOutlet weak var profileUserEmailLabel: UILabel!
    @IBOutlet weak var profileUserPostNumberLabel: UILabel!
    @IBOutlet weak var profileUserFollowerNumberLabel: UILabel!
    @IBOutlet weak var profileUserFollowingNumberLabel: UILabel!
    @IBOutlet weak var profileUserBio: UITextView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var selectUser: User?
    var postArray: [[String : Any]]? {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if selectUser == nil { selectUser = UserSingleton.shared.currentUser }
        
        if auth.currentUser?.uid != selectUser?.id {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
        self.dismissKeyboardWhenTapped()
        profileUserBio.isEditable = false
        profileUserBio.isSelectable = false
        profileImageView.layer.cornerRadius = 7.5
        self.collectionView.register(UINib(nibName: "ProfilePostCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "profilePostCollectionViewCell")
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 4
        self.collectionView.setCollectionViewLayout(layout, animated: true)

    }
    
    //MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        Firebase().getUserPosts(userId: selectUser!.id) { [weak self] postArray, error in
            guard error == nil else { return }
            guard let self = self else { return }
            self.postArray = postArray
        }
        navigationItem.title = selectUser?.username
        profileUsernameLabel.text = selectUser?.username
        profileUserEmailLabel.text = selectUser?.userEmail
        profileImageView.image = UIImage(data: selectUser!.userProfilePictureData)
        profileUserBio.text = selectUser?.userBio
        profileUserPostNumberLabel.text = String(selectUser!.postNumber)
        profileUserFollowerNumberLabel.text = String(selectUser!.followerNumber)
        profileUserFollowingNumberLabel.text = String(selectUser!.followingNumber)
    }
}

extension UserProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        postArray != nil ? postArray!.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "profilePostCollectionViewCell", for: indexPath) as? ProfilePostCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.imageView.downloadImage(from: URL(string: postArray![indexPath.row]["imageURL"] as! String))
        cell.layer.masksToBounds = false
        cell.backgroundColor = .clear
        return cell
    }
    
    //MARK: - SizeForItemAt
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let gridLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let widthPerItem = collectionView.frame.width / 2 - gridLayout.minimumInteritemSpacing
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    //MARK: - InsetForSectionAt
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1.0, left: 1.0, bottom: 1.0, right: 1.0)
    }
    
}
