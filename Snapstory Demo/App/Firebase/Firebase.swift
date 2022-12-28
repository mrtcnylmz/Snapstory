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

class Firebase {
    func resetPassword(controller: UIViewController, email: String) {
        controller.showIndicationSpinner()
        auth.sendPasswordReset(withEmail: email) { [weak controller] err in
            guard let self = controller else { return }
            self.removeIndicationSpinner()
            guard err == nil else {
                self.basicAlert(title: "⚠️ Error", message: err?.localizedDescription ?? "Error")
                return
            }
            self.basicAlert(title: "Success", message: "Please check your email for further steps.")
        }
    }
    
    func signIn(controller: UIViewController, email: String, password: String) {
        controller.showIndicationSpinner()
        auth.signIn(withEmail: email, password: password) { [weak controller] authResult, err in
            guard let self = controller else { return }
            self.removeIndicationSpinner()
            guard err == nil else {
                self.basicAlert(title: "⚠️ Error", message: err!.localizedDescription )
                return
            }
            guard Auth.auth().currentUser != nil else {
                self.basicAlert(title: "⚠️ Error", message: "Error.")
                return
            }
            self.performSegue(withIdentifier: "toTabBar", sender: nil)
        }
    }
    
    func signUp(controller: UIViewController, email: String, password: String, username: String?) {
        
    }
}
