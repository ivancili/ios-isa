//
//  Progressable.swift
//  Pokedex
//
//  Created by Infinum Student Academy on 23/07/2017.
//  Copyright © 2017 Ivan Ilic. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD

protocol Progressable {
    func showProgressHud(messageToShow message: String?)
    func hideProgressHud()
}

extension Progressable where Self: UIViewController {
    
    func showProgressHud(messageToShow message: String?) {
        let activity = MBProgressHUD.showAdded(to: self.view, animated: true)
        activity.label.text = "Loading"
        activity.detailsLabel.text = message ?? "Please wait..."
    }
    
    func hideProgressHud() {
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    
}
