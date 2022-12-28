//
//  UserSingleton.swift
//  Snapstory Demo
//
//  Created by Mertcan Yılmaz
//

import Foundation
import UIKit

class UserSingleton{
    var username = ""
    var userEmail = ""
    var userBio = ""
    var postNumber = 0
    var followerNumber = 0
    var followingNumber = 0
    var userProfilePicture : UIImage?
    var userProfilePictureURL = ""
    var followers = [String]()
    var following = [String]()
    
    static let sharedUserInfo = UserSingleton()
    
    private init(){
    }
}
