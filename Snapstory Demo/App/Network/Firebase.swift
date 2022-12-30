//
//  Firebase.swift
//  Snapstory Demo
//
//  Created by Mertcan Yılmaz on 28.12.2022.
//

import Foundation
import Firebase
import UIKit

let firestore = Firestore.firestore()
let auth = Auth.auth()
let storage = Storage.storage()

let defaultPhotoURL = URL(string: "https://firebasestorage.googleapis.com/v0/b/snapstory-1fcce.appspot.com/o/media%2F360_F_64676383_LdbmhiNM6Ypzb3FM4PPuFP9rHe7ri8Ju.jpeg?alt=media&token=bd694d5e-c524-4142-8df6-b31f00d25c20")

class Firebase {
    
    //MARK: - Get from storage
    func getFromStorage(url: String, complation: @escaping (Data?, Error?) -> Void) {
        storage.reference(forURL: url).getData(maxSize: 99999999999) { data, error in
            guard error == nil else {
                complation(nil ,error)
                return
            }
            complation(data, nil)
        }
    }
    
    //MARK: Sign Out
    func signOut(complation: @escaping (Error?) -> ()) {
        guard auth.currentUser != nil else {
            complation(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "No user logged in."]))
            return
        }
        do{
            try
            auth.signOut()
            complation(nil)
        }
        catch {
            complation(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Failed to sign out."]))
        }
    }
    
    //MARK: - Sign Up
    func createUser(email: String, password: String, username: String, complation: @escaping (AuthDataResult?, User?, Error?) -> ()) {
        auth.createUser(withEmail: email, password: password) { authResult, error in
            guard error == nil else {
                complation(nil, nil, error)
                return
            }
            self.profileChange(username: username, photoUrl: defaultPhotoURL!.absoluteString) { error in
                guard error == nil else {
                    complation(nil, nil, error)
                    return
                }
            }
            
            //TODO: - Remove useless entries in user
            let userInfoDictionary = [
                "email": email,
                "username": username,
                "bio": "Hi!",
                "profilePictureURL": defaultPhotoURL!.absoluteString,
                "numberOfPosts": 0,
                "numberOfFollowers": 0,
                "numberOfFollowing": 0,
                "following": [],
                "followers": [],
                "posts": []
            ] as [String: Any]
            
            let user = User(id: authResult!.user.uid,
                            username: username,
                            userEmail: email,
                            userBio: "Hi!",
                            postNumber: 0,
                            followerNumber: 0,
                            followingNumber: 0,
                            userProfilePictureData: try! Data(contentsOf: URL(string: defaultPhotoURL!.absoluteString)!),
                            userProfilePictureURL: defaultPhotoURL!.absoluteString,
                            followers: [],
                            following: [])
            
            firestore.collection("Users").document(authResult!.user.uid).setData(userInfoDictionary) { error in
                guard error == nil else {
                    complation(nil, nil, error)
                    return
                }
            }
            complation(authResult, user, nil)
        }
    }
    
    //MARK: - Profile Edit
    func profileChange(username: String?, photoUrl: String?, complation: @escaping (Error?) -> ()) {
        let changeRequest = auth.currentUser?.createProfileChangeRequest()
        if let username = username { changeRequest?.displayName = username }
        if let photoUrl = photoUrl { changeRequest?.photoURL = URL(string: photoUrl) }
        changeRequest?.commitChanges { error in
            complation(error)
        }
    }
    
    //MARK: - getUserInfo
    func getUserInfo(id: String, complation: @escaping (User?, Error?) -> Void) {
        let docRef = firestore.collection("Users").document(id)
        docRef.getDocument { document, error in
            guard error == nil else {
                complation(nil, error)
                return
            }
            guard document!.exists, let document = document else {
                complation(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Database error."]))
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
            
            complation(user, nil)
        }
    }
    
    //MARK: Get Posts
    func getFeedPosts(emailArray: [String], complation: @escaping (_ postArray: [[String : Any]]?, Error?) -> ()) {
        var postArray = [[String : Any]]()
        firestore.collection("Posts").whereField("postOwnerEmail", in: emailArray).order(by: "date", descending: true).getDocuments { snapshot, error in
            guard error == nil else {
                complation(nil, error)
                return
            }
            for document in snapshot!.documents{
                var post = document.data()
                post.updateValue(document.documentID, forKey: "postID")
                postArray.append(post)
            }
            complation(postArray, nil)
        }
    }
}
