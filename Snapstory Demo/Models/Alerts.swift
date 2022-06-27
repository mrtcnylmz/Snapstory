//
//  Alerts.swift
//  Snapstory Demo
//
//  Created by Mertcan Yılmaz
//

import Foundation
import UIKit

class AlertMaker{
    func makeAlert(`on` controller: UIViewController, title : String, message : String, okFunc : ((UIAlertAction) -> Void)?){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: okFunc)
        alert.addAction(okAction)
        controller.present(alert, animated: true)
    }
}
