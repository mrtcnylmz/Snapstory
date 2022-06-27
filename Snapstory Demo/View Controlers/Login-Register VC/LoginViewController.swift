//
//  LoginViewController.swift
//  Snapstory Demo
//
//  Created by Mertcan Yılmaz
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - loginButton
    @IBAction func loginButton(_ sender: Any) {
        Auth.auth().signIn(withEmail: userEmail.text!, password: userPassword.text!) { auth, err in
            if err != nil{
                AlertMaker().makeAlert(on: self, title: "⚠️ Error", message: err?.localizedDescription ?? "Error", okFunc: nil)
            }else if Auth.auth().currentUser != nil{
                self.performSegue(withIdentifier: "toTabBar", sender: nil)
            }
        }
    }

    // MARK: - forgotPasswordButton
    @IBAction func forgotPasswordButton(_ sender: Any) {
        let alert = UIAlertController(title: "🐟 Password Reset", message: "Please input you email.", preferredStyle: UIAlertController.Style.alert)
        alert.addTextField { UITextField in
            UITextField.placeholder = "User Email"
        }
        let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { UIAlertAction in
            if alert.textFields![0].text != nil {
                Auth.auth().sendPasswordReset(withEmail: alert.textFields![0].text!) { err in
                    if err != nil{
                        AlertMaker().makeAlert(on: self, title: "⚠️ Error", message: err?.localizedDescription ?? "Failure.", okFunc: nil)
                    }else {
                        AlertMaker().makeAlert(on: self, title: "Success", message: "Please check your email for further steps.", okFunc: nil)
                    }
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.present(alert, animated: true)
    }
}
