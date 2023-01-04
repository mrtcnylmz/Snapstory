//
//  User.swift
//  Snapstory Demo
//
//  Created by Mertcan Yılmaz on 28.12.2022.
//

import Foundation
import UIKit
import FirebaseFirestoreSwift

// MARK: - User
struct User: Codable {
    let id: String
    let username: String
    let userEmail: String
    let userBio: String
    let postNumber: Int
    let followerNumber: Int
    let followingNumber: Int
    let userProfilePictureData: Data
    let userProfilePictureURL: String
    let followers: [String]
    let following: [String]

//    enum CodingKeys: String, CodingKey {
//        case id = "id"
//        case userId = "userId"
//        case username = "username"
//        case userEmail = "userEmail"
//        case userBio = "userBio"
//        case postNumber = "postNumber"
//        case followerNumber = "followerNumber"
//        case followingNumber = "followingNumber"
//        case userProfilePictureData = "userProfilePicture"
//        case userProfilePictureURL = "userProfilePictureURL"
//        case followers = "followers"
//        case following = "following"
//    }
}
