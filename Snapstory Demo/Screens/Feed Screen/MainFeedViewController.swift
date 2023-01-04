//
//  MainFeedViewController.swift
//  Snapstory Demo
//
//  Created by Mertcan Yılmaz
//

import UIKit
import Firebase

class MainFeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyFeedCell: UIView!
    
    var firebasePostDataArray = [[String:Any]]() {
        didSet{ self.tableView.reloadData() }
    }
    var currentUser : User? {
        didSet{ self.getPostsFromFirebase() }
    }

    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        Firebase().getCurrentUser { [weak self] user in
            guard let self = self else { return }
            self.currentUser = user
            UserSingleton.shared.currentUser = user
        }
    }
    
    // MARK: - getPostsFromFirebase
    func getPostsFromFirebase(){
        if !(currentUser!.following.isEmpty) || currentUser!.postNumber != 0 {
            var queryArray = currentUser!.following
            queryArray.append(auth.currentUser!.uid)
            
            Firebase().getFeedPosts(idArray: queryArray) { [weak self] postArray, error in
                guard let self = self else { return }
                guard error == nil else {
                    self.basicAlert(title: "Error", message: error!.localizedDescription)
                    return
                }
                self.firebasePostDataArray = postArray!
            }
        }else {
            //reset array
        }
    }
    
    // MARK: - numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        firebasePostDataArray.count > 0 ? firebasePostDataArray.count : 1
    }
    
    // MARK: - cellForRowAt
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if firebasePostDataArray.isEmpty{
            return tableView.dequeueReusableCell(withIdentifier: "emptyTableCell") as! EmptyFeedTableViewCell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "postCell") as! PostCellTableViewCell
            Firebase().getUserInfo(id: firebasePostDataArray[indexPath.row]["postOwnerId"] as! String, complation: { user, error in
                guard error == nil else {
                    self.basicAlert(title: "Error", message: error!.localizedDescription)
                    return
                }
                cell.postProfilePicture.downloadImage(from: URL(string: user!.userProfilePictureURL))
                cell.postUsername.text = user!.username
            })
            cell.postID = ((firebasePostDataArray[indexPath.row]["postID"] as! String))
            cell.postLiked = (firebasePostDataArray[indexPath.row]["whoLiked"] as! Array<String>).contains(auth.currentUser!.email!)
            cell.postDescription.text = (firebasePostDataArray[indexPath.row]["imageDescription"] as? String)
            cell.postLocation.text = (firebasePostDataArray[indexPath.row]["postLocation"] as? String)
            cell.postLikes = firebasePostDataArray[indexPath.row]["likes"] as! Int
            cell.postUserEmail.text = (firebasePostDataArray[indexPath.row]["postOwnerEmail"] as? String)
            let postDate = firebasePostDataArray[indexPath.row]["date"] as! Timestamp
            let postSince = Int(postDate.dateValue().distance(to: Date.now))
            cell.postDate.text = sinceDate(secondsPassed: postSince)
            cell.postImageView.downloadImage(from: URL(string: firebasePostDataArray[indexPath.row]["imageURL"] as! String))
            return cell
        }
    }
    
    // MARK: - sinceDate
    func sinceDate(secondsPassed sp : Int) -> String{
        if sp / 86400 >= 1{
            return "\(sp / 86400) days ago"
        }else if sp / 3600 % 24 >= 1{
            return "\(sp / 3600 % 24) hours ago"
        }else if sp / 60 % 60 >= 1{
            return "\(sp / 60 % 60) minutes ago"
        }else {
            return "\(sp % 60) seconds ago"
        }
    }
}
