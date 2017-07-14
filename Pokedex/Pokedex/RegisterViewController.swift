//
//  RegisterViewController.swift
//  Pokedex
//
//  Created by Infinum Student Academy on 14/07/2017.
//  Copyright © 2017 Ivan Ilic. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func signupButtonTouched(_ sender: Any) {
        // Alamofire request
        // If success -> navigation to Home
    }
    
}
