//
//  RegisterViewController.swift
//  Pokedex
//
//  Created by Infinum Student Academy on 14/07/2017.
//  Copyright © 2017 Ivan Ilic. All rights reserved.
//

import UIKit
import Alamofire
import CodableAlamofire

class RegisterViewController: UIViewController, Alertable, Progressable {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var signUpButtonBottomConstraint: NSLayoutConstraint!
    
    private weak var notificationTokenKeyboardWillShow: NSObjectProtocol?
    private weak var notificationTokenKeyboardWillHide: NSObjectProtocol?
    private weak var signupRequest: DataRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        notificationTokenKeyboardWillShow = NotificationCenter
            .default
            .addObserver(forName: Notification.Name.UIKeyboardWillShow, object: nil, queue: OperationQueue.main) { [weak self] notification in
                
                if let userInfo = notification.userInfo, let frame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                    self?.signUpButtonBottomConstraint.constant = frame.height
                } else {
                    return
                }
        }
        
        notificationTokenKeyboardWillHide = NotificationCenter
            .default
            .addObserver(forName: Notification.Name.UIKeyboardWillHide, object: nil, queue: OperationQueue.main) { [weak self] notification in
                self?.signUpButtonBottomConstraint.constant = 0
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        signupRequest?.cancel()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(notificationTokenKeyboardWillShow!)
        NotificationCenter.default.removeObserver(notificationTokenKeyboardWillHide!)
    }
    
    // MARK: - Sign up API call -
    @IBAction func signupButtonTouched(_ sender: Any) {
        
        showProgressHud(messageToShow: "Registering new user...")
        
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
                hideProgressHud()
                
                let title = "Error during registration"
                let message = "Please provide email, nickname, password and password confirmation."
                showAlertWithOK(with: title, message: message, nil)
                
                return
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
        
        signupRequest = Alamofire
            .request(
                "https://pokeapi.infinum.co/api/v1/users",
                method: .post,
                parameters: params)
            .validate()
            .responseDecodableObject { (response: DataResponse<UserModel>) in
                
                switch response.result {
                case .success:
                    self.hideProgressHud()
                    HomeViewController.switchToHomeScreen(self.navigationController, dataToInject: response.value!)
                    
                case .failure:
                    self.hideProgressHud()
                    
                    let title = "Invalid login data"
                    let message = "Please provide email, nickname, password and password confirmation."
                    self.showAlertWithOK(with: title, message: message, nil)
                    
                    self.emailTextField.text = ""
                    self.nicknameTextField.text = ""
                    self.passwordTextField.text = ""
                    self.confirmPasswordTextField.text = ""
                    
                }
                
        }
        
        
    }
    
}
