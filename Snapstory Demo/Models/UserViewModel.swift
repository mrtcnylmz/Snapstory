//
//  UserViewModel.swift
//  Snapstory Demo
//
//  Created by Mertcan Yılmaz on 28.12.2022.
//

import Foundation

struct UserViewModel {
    let user : User
}

extension UserViewModel {
    var id: String {
        return self.user.id
    }
    
    var username: String {
        return self.user.username
    }
    
    var userEmail: String {
        return self.user.userEmail
    }
    
    var userBio: String {
        return self.user.userBio
    }
    
    var postNumber: Int {
        return self.user.postNumber
    }
    
    var followerNumber: Int {
        return self.user.followerNumber
    }
    
    var followingNumber: Int {
        return self.user.followingNumber
    }
    
    var userProfilePictureData: Data {
        return self.user.userProfilePictureData
    }
    
    var userProfilePictureURL: String {
        return self.user.userProfilePictureURL
    }
    
    var followers: [String] {
        return self.user.followers
    }
    
    var following: [String] {
        return self.user.following
    }
    
//    func numberOfRowsInSection() -> Int {
//        return 3
//    }
}
