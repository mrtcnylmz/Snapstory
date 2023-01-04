//
//  SettingsViewController.swift
//  Snapstory Demo
//
//  Created by Mertcan Yılmaz
//

import UIKit
import Firebase

class SettingsViewController: UIViewController{
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Settings"
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0:
                return 3
            default:
                return 2
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case 0:
                return "USER INFO"
            default:
                return "USER SETTINGS"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var cellConfig = cell.defaultContentConfiguration()
        switch indexPath.section {
            case 0:
                switch indexPath.row {
                    case 0:
                        cellConfig.text = "Name"
                        cellConfig.secondaryText = auth.currentUser?.displayName
                        cellConfig.image = UIImage(systemName: "person")
                        cell.contentConfiguration = cellConfig
                        return cell
                    case 1:
                        cellConfig.text = "Email"
                        cellConfig.secondaryText = auth.currentUser?.email
                        cellConfig.image = UIImage(systemName: "envelope")
                        cell.contentConfiguration = cellConfig
                        return cell
                    default:
                        cellConfig.text = "User ID"
                        cellConfig.secondaryText = auth.currentUser?.uid
                        cellConfig.image = UIImage(systemName: "number")
                        cell.contentConfiguration = cellConfig
                        return cell
                }
            default:
                switch indexPath.row {
                    case 0:
                        cellConfig.text = "Reset Password"
                        cellConfig.image = UIImage(systemName: "key")
                        cell.contentConfiguration = cellConfig
                        return cell
                    default:
                        cellConfig.text = "Sign Out"
                        cellConfig.textProperties.color = .red
                        cellConfig.image = .remove
                        cell.contentConfiguration = cellConfig
                        return cell
                }
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1{
            switch indexPath.row {
                case 0:
                    //MARK: Reset Password
                    self.showIndicationSpinner()
                    auth.sendPasswordReset(withEmail: (auth.currentUser?.email)!) { [weak self] error in
                        guard let self = self else { return }
                        self.removeFromParent()
                        guard error == nil else {
                            self.basicAlert(title: "Error", message: error!.localizedDescription)
                            return
                        }
                    }
                default:
                    //MARK: Sign Out
                    self.showIndicationSpinner()
                    Firebase().signOut { error in
                        self.removeFromParent()
                        guard error == nil else { return }
                        self.basicAlert(title: "Success", message: "Sign out successfull") { _ in
                            self.performSegue(withIdentifier: "toLoginViewController", sender: nil)
                        }
                    }
            }
        }
    }
}
