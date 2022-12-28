//
//  CirclesViewController.swift
//  Snapstory Demo
//
//  Created by Mertcan Yılmaz
//

import UIKit
import Firebase

class CirclesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var a = [[String]]()
    var b = [[String]]()
    
    lazy var total = [a,b]
    lazy var selectedSegment = total[0]
    var searchedUser = [String: Any]()
    let firestore = Firestore.firestore()
    
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        a = [UserSingleton.sharedUserInfo.following]
        b = [UserSingleton.sharedUserInfo.followers]
        total = [a,b]
        tableView.reloadData()
    }
    
    //MARK: - cellForRowAt
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var conConf = cell.defaultContentConfiguration()
        conConf.text = selectedSegment[indexPath.section][indexPath.row]
        //conConf.secondaryText =
        //conConf.image = .add
        cell.contentConfiguration = conConf
        return cell
    }
    
    //MARK: - numberOfSections
    func numberOfSections(in tableView: UITableView) -> Int {
        selectedSegment.count
    }
    
    //MARK: - numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedSegment[section].count
    }
    
    //MARK: - titleForHeaderInSection
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch segmentedControl.selectedSegmentIndex{
        case 0:
            return "People You Follow"
        default:
            return "People Who Follow You"
            }
        }
    
    //MARK: - sendButtonClicked
    @IBAction func sendButtonClicked(_ sender: Any) {
        if emailTextField.text == UserSingleton.sharedUserInfo.userEmail{
            self.tabBarController?.selectedIndex = 3
        }else{
            firestore.collection("User_Infos").whereField("email", in: [emailTextField.text!]).getDocuments { quarySnapshpt, error in
                if quarySnapshpt!.documents.isEmpty {
                    self.basicAlert(title: "Error", message: "User haven't been found, try again.")
                }else{
                    self.searchedUser = quarySnapshpt!.documents.first!.data()
                    self.performSegue(withIdentifier: "toSearchedProfile", sender: nil)
                }
            }
        }
    }
    
    //MARK: - prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSearchedProfile"{
            let sentData = segue.destination as! SearchPopUpViewController
            sentData.recievedData = searchedUser
        }
    }
    
    // MARK: - segmentedControlValueChanged
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
        case 0:
            selectedSegment = total[0]
        default:
            selectedSegment = total[1]
        }
        tableView.reloadData()
    }
}
