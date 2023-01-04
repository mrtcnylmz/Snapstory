//
//  UIViewController+Extension.swift
//  Snapstory Demo
//

import UIKit

var aView : UIView?

extension UIViewController {
    
    //MARK: - Show Indication
    func showIndicationSpinner() {
        aView = UIView(frame: self.view.frame)
        aView?.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.95)
        
        let ai = UIActivityIndicatorView(style: .large)
        ai.center = aView!.center
        ai.startAnimating()
        aView?.addSubview(ai)
        self.view.addSubview(aView!)
        
        // Timeout
        Timer.scheduledTimer(withTimeInterval: 20, repeats: false) { _ in
            self.removeIndicationSpinner()
        }
    }
    
    //MARK: - Remove Indication
    func removeIndicationSpinner() {
        aView?.removeFromSuperview()
        aView = nil
    }
    
    //MARK: - Dismiss Keyboard When Tapped
    func dismissKeyboardWhenTapped() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyb))
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    @objc private func hideKeyb(){
        view.endEditing(true)
    }
}
