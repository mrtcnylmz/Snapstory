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
    
    var searchedUser : QueryDocumentSnapshot?
    var followers = [String]()
    var following = [String]()
    var selectedSegment = [String]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dismissKeyboardWhenTapped()
        tableView.delegate = self
        tableView.dataSource = self
        
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.systemIndigo], for: .normal)
        
        Firebase().getCurrentUser { [weak self] user in
            guard let self = self else { return }
            self.following = user.following
            self.followers = user.followers
            self.selectedSegment = self.following
        }
    }
    
    //MARK: - cellForRowAt
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard !selectedSegment.isEmpty else {
            return segmentedControl.selectedSegmentIndex == 0
            ? tableView.dequeueReusableCell(withIdentifier: "emptyFollowingCell") as! EmptyFollowingTableViewCell
            : tableView.dequeueReusableCell(withIdentifier: "emptyFollowersCell") as! EmptyFollowersTableViewCell
        }
        let cell = UITableViewCell()
        var cellConfig = cell.defaultContentConfiguration()
        Firebase().getUserInfo(id: selectedSegment[indexPath.row]) { user, error in
            guard error == nil else { return }
            cellConfig.text = user!.username
            cellConfig.secondaryText = user!.userEmail
            cellConfig.textProperties.color = .systemIndigo
            cellConfig.secondaryTextProperties.color = .systemIndigo
            cellConfig.image = UIImage(data: user!.userProfilePictureData)
            cellConfig.imageProperties.maximumSize = CGSize(width: cell.frame.size.height - 8, height: cell.frame.size.height - 8)
            cellConfig.imageProperties.cornerRadius = CGFloat(5)
            cell.contentConfiguration = cellConfig
            cell.isUserInteractionEnabled = true
        }
        return cell
    }
    
    //MARK: - numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        selectedSegment.count != 0 ? selectedSegment.count : 1
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Firebase().getUserInfo(id: selectedSegment[indexPath.row]) { user, error in
            let userProfile = self.storyboard!.instantiateViewController(identifier: "userProfile") as! UserProfileViewController
            userProfile.selectUser = user
            userProfile.modalPresentationStyle = .fullScreen
            userProfile.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(userProfile, animated: true)
        }
    }
    
    //MARK: - sendButtonClicked
    @IBAction func sendButtonClicked(_ sender: Any) {
        if emailTextField.text == auth.currentUser?.email{
            self.tabBarController?.selectedIndex = 3
        }else{
            
            firestore.collection("Users").whereField("email", in: [emailTextField.text!]).getDocuments { quarySnapshpt, error in
                if quarySnapshpt!.documents.isEmpty {
                    self.basicAlert(title: "Error", message: "User haven't been found, try again.")
                }else if self.following.contains(quarySnapshpt!.documents.first!.documentID){
                    self.basicAlert(title: "Error", message: "You already follow this user.")
                }else{
                    print(self.following)
                    print(quarySnapshpt!.documents.first!.documentID)
                    self.searchedUser = quarySnapshpt!.documents.first!
                    self.performSegue(withIdentifier: "toSearchedProfile", sender: nil)
                }
            }
        }
    }
    
    //MARK: - prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSearchedProfile"{
            let sentData = segue.destination as! SearchPopUpViewController
            sentData.userFollowingList = following
            sentData.recievedData = searchedUser
        }
    }
    
    // MARK: - segmentedControlValueChanged
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
            case 0:
                selectedSegment = following
            default:
                selectedSegment = followers
        }
    }
}
