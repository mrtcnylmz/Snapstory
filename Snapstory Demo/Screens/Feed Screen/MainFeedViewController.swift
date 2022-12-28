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
    
    let firestore = Firestore.firestore()
    let auth = Auth.auth()
    var firebasePostDataArray : [[String:Any]] = []
    var perPostUsername: String = ""
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        getUserInfo { done in
        }
    }
    
    // MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        getUserInfo { done in
            if done{
                self.getPostsFromFirebase()
            }
        }
    }
    
    // MARK: - getPostsFromFirebase
    func getPostsFromFirebase(){
        if !(UserSingleton.sharedUserInfo.following.isEmpty) || UserSingleton.sharedUserInfo.postNumber != 0{
            var queryArray = UserSingleton.sharedUserInfo.following
            queryArray.append(UserSingleton.sharedUserInfo.userEmail)
            firestore.collection("Posts")
                .whereField("postOwnerEmail", in: queryArray)
                .order(by: "date", descending: true)
                .getDocuments { [weak self] snapshot, error in
                    guard let self = self else { return }
                    
                    guard error == nil else {
                        self.basicAlert(title: "Error", message: error!.localizedDescription)
                        return
                    }
                    
                    self.firebasePostDataArray.removeAll()
                    for document in snapshot!.documents{
                        var tmp = document.data()
                        tmp.updateValue(document.documentID, forKey: "postID")
                        
                        self.firebasePostDataArray.append(tmp)
                    }
                    self.tableView.reloadData()
                }
        }
    }
    
    // MARK: - numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if firebasePostDataArray.count > 0{
            print(firebasePostDataArray.count," v2")
            return firebasePostDataArray.count
        }
        return 1
    }
    
    // MARK: - cellForRowAt
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if firebasePostDataArray.isEmpty{
            let cell = tableView.dequeueReusableCell(withIdentifier: "emptyTableCell") as! EmptyFeedTableViewCell
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "postCell") as! PostCellTableViewCell
            var postProfilePictureURL = ""
            firestore.collection("User_Infos").whereField("email", in: [(firebasePostDataArray[indexPath.row]["postOwnerEmail"] as? String)!]).getDocuments { quarySnapshpt, error in
                if quarySnapshpt!.documents.isEmpty {
                    //
                }else{
                    postProfilePictureURL = quarySnapshpt!.documents.first!.data()["profilePictureURL"] as! String
                    let data = try? Data(contentsOf: URL(string: postProfilePictureURL)!)
                    cell.postProfilePicture.image = UIImage(data: data!)
                }
            }
            
            cell.postID = ((firebasePostDataArray[indexPath.row]["postID"] as! String))
            cell.postLiked = (firebasePostDataArray[indexPath.row]["whoLiked"] as! Array<String>).contains(auth.currentUser!.email!)
            getUsername(email: firebasePostDataArray[indexPath.row]["postOwnerEmail"] as! String, completion: { username in
                cell.postUsername.text = username
            })
            //cell.postUsername.text = (firebasePostDataArray[indexPath.row]["postOwnerUsername"] as? String)
            cell.postDescription.text = (firebasePostDataArray[indexPath.row]["imageDescription"] as? String)
            cell.postLocation.text = (firebasePostDataArray[indexPath.row]["postLocation"] as? String)
            cell.postLikeNumber.text = "\(String(firebasePostDataArray[indexPath.row]["likes"] as! Int)) likes"
            cell.postUserEmail.text = (firebasePostDataArray[indexPath.row]["postOwnerEmail"] as? String)
            let postDate = firebasePostDataArray[indexPath.row]["date"] as! Timestamp
            let postSince = Int(postDate.dateValue().distance(to: Date.now))
            cell.postDate.text = sinceDate(secondsPassed: postSince)
            let postImgRef = Storage.storage().reference(forURL: firebasePostDataArray[indexPath.row]["imageURL"] as! String)
            postImgRef.getData(maxSize: 99999999999) { data, error in
                if error == nil{
                    cell.postImageView.image = UIImage(data: data!)
                }
            }
            
            return cell
        }
    }
    
    // MARK: - getUserInfo
    func getUserInfo(completion: @escaping (_ done: Bool) -> Void){
        var userData = [String: Any]()
        let currentUserQuary = firestore.collection("User_Infos").whereField("email", in: [auth.currentUser?.email as Any])
        currentUserQuary.getDocuments { [weak self] snapshot, error in
            for dat in snapshot!.documents{
                userData = dat.data()
                UserSingleton.sharedUserInfo.userEmail = (self?.auth.currentUser?.email)!
                UserSingleton.sharedUserInfo.username = (self?.auth.currentUser?.displayName ?? "")
                UserSingleton.sharedUserInfo.userBio = (userData["bio"] as? String) ?? ""
                UserSingleton.sharedUserInfo.userProfilePictureURL = userData["profilePictureURL"] as! String
                UserSingleton.sharedUserInfo.followerNumber = userData["numberOfFollowers"] as! Int
                UserSingleton.sharedUserInfo.followingNumber = userData["numberOfFollowing"] as! Int
                UserSingleton.sharedUserInfo.postNumber = userData["numberOfPosts"] as! Int
                UserSingleton.sharedUserInfo.followers = userData["followers"] as! Array<String>
                UserSingleton.sharedUserInfo.following = userData["following"] as! Array<String>
                let data = try? Data(contentsOf: URL(string: userData["profilePictureURL"] as! String)!)
                UserSingleton.sharedUserInfo.userProfilePicture = UIImage(data: data!)
                let done = true
                completion(done)
            }
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
    
    // MARK: - getUsername for posts
    func getUsername(email: String, completion: @escaping (_ username: String) -> Void){
        Firestore.firestore().collection("User_Infos").whereField("email", in: [email]).getDocuments { snaps, error in
            guard error == nil else {
                self.basicAlert(title: "Error", message: error!.localizedDescription)
                return
            }
            guard snaps!.documents.isEmpty else {
                completion(snaps!.documents.first!.data()["username"] as! String)
                return
            }
        }
    }
}
