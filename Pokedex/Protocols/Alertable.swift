//
//  AlertHandling+ViewControllers
//  Pokedex
//
//  Created by Infinum Student Academy on 20/07/2017.
//  Copyright © 2017 Ivan Ilic. All rights reserved.
//

import Foundation
import UIKit

protocol Alertable {
    func showAlertWithOK(with title: String, message: String)
    func showAlertWithCancelAndOK(with title: String, message: String, _ handleOK: ((UIAlertAction) -> Void)?, _ handleCancel: ((UIAlertAction) -> Void)?)
}

extension Alertable where Self: UIViewController {
    
    func showAlertWithOK(with title: String, message: String) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    func showAlertWithCancelAndOK(with title: String, message: String, _ handleOK: ((UIAlertAction) -> Void)?, _ handleCancel: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: handleOK))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: handleCancel))
        
        self.present(alert, animated: true)
    }
    
}
