//
//  RegisterViewController.swift
//  Snapstory Demo
//
//  Created by Mertcan Yılmaz
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    @IBOutlet weak var registerEmail: UITextField!
    @IBOutlet weak var registerUsername: UITextField!
    @IBOutlet weak var registerPassword: UITextField!
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dismissKeyboardWhenTapped()
    }
    
    // MARK: - doneButton
    @IBAction func doneButton(_ sender: Any) {
        self.showIndicationSpinner()
        guard registerUsername.text!.count >= 3 else {
            self.removeIndicationSpinner()
            self.basicAlert(title: "Error", message: "Username too short.")
            return
        }
        Firebase().createUser(email: registerEmail.text!, password: registerPassword.text!, username: registerUsername.text!) { [weak self] authresult, user, error in
            guard let self = self else { return }
            self.removeIndicationSpinner()
            guard error == nil else {
                self.basicAlert(title: "⚠️ Error", message: error!.localizedDescription)
                return
            }
            guard let data = try? PropertyListEncoder().encode(user) else {
                fatalError("Failed to set current user.")
            }
            UserDefaults.standard.set(data, forKey: "currentUserInfo")
            self.basicAlert(title: "Success", message: "User created!") { _ in
                self.performSegue(withIdentifier: "toTabBar", sender: nil)
            }
        }
    }
}
