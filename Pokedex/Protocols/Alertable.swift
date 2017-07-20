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
    func showAlert(with title: String, message: String)
}

extension Alertable where Self: UIViewController {
    
    func showAlert(with title: String, message: String) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            print("OK")
        })
        self.present(alert, animated: true)
    }
    
}
