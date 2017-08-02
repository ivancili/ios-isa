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
    
    @IBOutlet weak var signUpButton: UIButton!
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
        
        UIApplication.shared.statusBarStyle = .lightContent
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        keyboardHandlingSetup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.shared.statusBarStyle = .default
        signupRequest?.cancel()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(notificationTokenKeyboardWillShow!)
        NotificationCenter.default.removeObserver(notificationTokenKeyboardWillHide!)
    }
    
    // MARK: - Keyboard handling setup -
    func keyboardHandlingSetup() {
        
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
            animateSignUpButtonWithColor(UIColor.red)
            
            let title = "Registration failed"
            self.showAlertWithOK(with: title, message: nil, nil)
            
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
                    self.animateSignUpButtonWithColor(UIColor.green)
                    
                    HomeViewController.switchToHomeScreen(self.navigationController, dataToInject: response.value!)
                    
                case .failure:
                    self.hideProgressHud()
                    self.animateSignUpButtonWithColor(UIColor.red)
                    
                    let title = "Registration failed"
                    self.showAlertWithOK(with: title, message: nil, nil)
                    
                    self.emailTextField.text = ""
                    self.nicknameTextField.text = ""
                    self.passwordTextField.text = ""
                    self.confirmPasswordTextField.text = ""
                    
                }
                
        }
        
        
    }
    
    // MARK: - Animations -
    func animateSignUpButtonWithColor(_ color: UIColor) {

        let initialColor = self.signUpButton.backgroundColor
        self.signUpButton.backgroundColor = color
        
        UIView.animate(withDuration: 1, animations: {
            self.signUpButton.backgroundColor = initialColor
        })

    }
    
}
