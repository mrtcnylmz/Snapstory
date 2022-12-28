//
//  UIViewController+Alerts.swift
//  Snapstory Demo
//
//  Created by Mertcan Yılmaz on 26.12.2022.
//

import UIKit

extension UIViewController {
    
    //MARK: Basic
    func basicAlert(title: String, message: String, buttonTitle: String = "Ok", buttonStyle: UIAlertAction.Style = .default, buttonAction: ((UIAlertAction) -> Void)? = nil){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let button = UIAlertAction(title: buttonTitle, style: buttonStyle, handler: buttonAction)
        alert.addAction(button)
        self.present(alert, animated: true)
    }
    func basicSheetAlert(title: String, message: String, buttonTitle: String = "Ok", buttonStyle: UIAlertAction.Style = .default){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let button = UIAlertAction(title: "Ok", style: buttonStyle)
        alert.addAction(button)
        self.present(alert, animated: true)
    }
}
