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

class RegisterViewController: UIViewController, Alertable {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    weak var notificationTokenKeyboardWillShow: NSObjectProtocol?
    weak var notificationTokenKeyboardWillHide: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        notificationTokenKeyboardWillShow = NotificationCenter
            .default
            .addObserver(forName: Notification.Name.UIKeyboardWillShow, object: nil, queue: OperationQueue.main) { [weak self] notification in
                // keyboard is about to show
                guard
                    let userInfo = notification.userInfo,
                    let frame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
                        return
                }
                let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: frame.height, right: 0)
                self?.scrollView.contentInset = contentInset
        }
        
        notificationTokenKeyboardWillHide = NotificationCenter
            .default
            .addObserver(forName: Notification.Name.UIKeyboardWillHide, object: nil, queue: OperationQueue.main) { [weak self] notification in
                // keyboard is about to hide
                self?.scrollView.contentInset = UIEdgeInsets.zero
        }
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(notificationTokenKeyboardWillShow!)
        NotificationCenter.default.removeObserver(notificationTokenKeyboardWillHide!)
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
                MBProgressHUD.hide(for: self.view, animated: true)
                
                let title = "Error during registration"
                let message = "Please provide email, nickname, password and password confirmation."
                showAlert(with: title, message: message)
                
                return print("All data must be provided.")
        }
        
        
        let params = [
            "data": [
                "type" : "users",
                "attributes" : [
                    "username" : nickname,
                    "email" : email,
                    "password" : password,
                    "password_confirmation" : passwordConfirmation
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
                    HomeViewController.switchToHomeScreen(self.navigationController, dataToInject: response.value!)
                    
                case .failure:
                    MBProgressHUD.hide(for: self.view, animated: true)
                    
                    if let data = response.data {
                        let errorResponse = try? JSONDecoder().decode(JSONError.self, from: data)
                        print(errorResponse!.allErrorsAsString())
                    }
                    
                    let title = "Invalid login data"
                    let message = "Please provide email, nickname, password and password confirmation."
                    self.showAlert(with: title, message: message)
                    
                    self.emailTextField.text = ""
                    self.nicknameTextField.text = ""
                    self.passwordTextField.text = ""
                    self.confirmPasswordTextField.text = ""
                    
                }
                
        }
        
        
    }
    
}
