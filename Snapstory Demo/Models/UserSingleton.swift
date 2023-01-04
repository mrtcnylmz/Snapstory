//
//  UserSingleton.swift
//  Snapstory Demo
//
//  Created by Mertcan Yılmaz
//

import Foundation
import UIKit

class UserSingleton{
    var currentUser: User?
    
    static let shared = UserSingleton()
    
    private init(){
    }
}
