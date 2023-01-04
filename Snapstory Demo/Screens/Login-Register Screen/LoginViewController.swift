//
//  LoginViewController.swift
//  Snapstory Demo
//
//  Created by Mertcan Yılmaz
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class LoginViewController: UIViewController {
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dismissKeyboardWhenTapped()
    }
    
    // MARK: - loginButton
    @IBAction func loginButton(_ sender: Any) {
        self.showIndicationSpinner()
        auth.signIn(withEmail: userEmail.text!, password: userPassword.text!) { [weak self] authResult, error in
            guard let self = self else { return }
            self.removeIndicationSpinner()
            guard error == nil else {
                self.basicAlert(title: "Error", message: error!.localizedDescription)
                return
            }
            self.performSegue(withIdentifier: "toTabBar", sender: nil)
        }
    }
    
    // MARK: - forgotPasswordButton
    @IBAction func forgotPasswordButton(_ sender: Any) {
        let alert = UIAlertController(title: "🐟 Password Reset",
                                      message: "Please input you email.",
                                      preferredStyle: .alert)
        
        alert.addTextField { UITextField in UITextField.placeholder = "User Email" }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let okAction = UIAlertAction(title: "Ok", style: .default){ _ in
            self.showIndicationSpinner()
            auth.sendPasswordReset(withEmail: alert.textFields![0].text!) { [weak self] error in
                guard let self = self else { return }
                self.removeIndicationSpinner()
                guard error == nil else {
                    self.basicAlert(title: "Error", message: error!.localizedDescription)
                    return
                }
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.present(alert, animated: true)
    }
    
}
