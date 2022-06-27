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
            AlertMaker().makeAlert(on: self, title: "Success", message: "Sign Out Succesfull!", okFunc: { _ in
                self.performSegue(withIdentifier: "toLoginViewController", sender: nil)
            })
        }
        catch {
            AlertMaker().makeAlert(on: self, title: "Error", message: "Failed to Sign Out", okFunc: nil)
        }
    }
}
