//
//  SettingsViewController.swift
//  Snapstory Demo
//
//  Created by Mertcan Yılmaz
//

import UIKit
import Firebase

class SettingsViewController: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Settings"
    }
    
    //MARK: - sgout
    @IBAction func sgout(_ sender: Any) {
        do{
            try
            Auth.auth().signOut()
            self.basicAlert(title: "Success", message: "Sign Out Succesfull!", buttonAction: { _ in
                self.performSegue(withIdentifier: "toLoginViewController", sender: nil)
            })
        }
        catch {
            self.basicAlert(title: "Error", message: "Failed to Sign Out")
        }
    }
}
