//
//  RegisterViewController.swift
//  Pokedex
//
//  Created by Infinum Student Academy on 14/07/2017.
//  Copyright © 2017 Ivan Ilic. All rights reserved.
//

import UIKit
import Alamofire
import MBProgressHUD
import CodableAlamofire

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        NotificationCenter
            .default
            .addObserver(forName: Notification.Name.UIKeyboardWillShow, object: nil, queue: OperationQueue.main) { notification in
                // keyboard is about to show
                guard
                    let userInfo = notification.userInfo,
                    let frame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
                        return
                }
                let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: frame.height, right: 0)
                self.scrollView.contentInset = contentInset
        }
        
        NotificationCenter
            .default
            .addObserver(forName: Notification.Name.UIKeyboardWillHide, object: nil, queue: OperationQueue.main) { notification in
                // keyboard is about to hide
                self.scrollView.contentInset = UIEdgeInsets.zero
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @IBAction func signupButtonTouched(_ sender: Any) {
        
        // Alamofire request
        // If success -> navigation to Home
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        guard
            let email = emailTextField.text,
            let nickname = nicknameTextField.text,
            let password = passwordTextField.text,
            let passwordConfirmation = confirmPasswordTextField.text,
            !email.isEmpty,
            !nickname.isEmpty,
            !password.isEmpty,
            !passwordConfirmation.isEmpty
            else {
                return print("All data must be provided.")
        }
        
        
        let params = [
            "data": [
                "type" : "users",
                "attributes" : [
                    "username" : String(nickname),
                    "email" : String(email),
                    "password" : String(password),
                    "password_confirmation" : String(passwordConfirmation)
                ]
            ]
        ]
        
        Alamofire
            .request(
                "https://pokeapi.infinum.co/api/v1/users",
                method: .post,
                parameters: params)
            .validate()
            .responseDecodableObject { (response: DataResponse<User>) in
                
                switch response.result {
                case .success:
                    
                    MBProgressHUD.hide(for: self.view, animated: true)
                    let bundle = Bundle.main
                    let storyboard = UIStoryboard(name: "Main", bundle: bundle)
                    let homeViewController = storyboard.instantiateViewController(
                        withIdentifier: "HomeViewController"
                    )
                    self.navigationController?.setViewControllers([homeViewController], animated: true)
                    
                case .failure:
                    
                    if let data = response.data {
                        let json = String(data: data, encoding: String.Encoding.utf8)
                        print("FAILURE: \(String(describing: json))")
                    }
                    
                }
                
        }
        
        
    }
    
}
