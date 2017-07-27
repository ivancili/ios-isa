//
//  LoginViewController.swift
//  Pokedex
//
//  Created by Infinum Student Academy on 08/07/2017.
//  Copyright © 2017 Ivan Ilic. All rights reserved.
//

import UIKit
import CodableAlamofire
import Alamofire

class LoginViewController: UIViewController, Alertable, Progressable {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var buttonsBottomConstraint: NSLayoutConstraint!
    
    private weak var notificationTokenKeyboardWillShow: NSObjectProtocol?
    private weak var notificationTokenKeyboardWillHide: NSObjectProtocol?
    private weak var loginRequest: DataRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        emailTextField.text = UserDefaults.standard.value(forKey: UserDefaultsModel.email.rawValue) as? String ?? ""
        passwordTextField.text = UserDefaults.standard.value(forKey: UserDefaultsModel.password.rawValue) as? String ?? ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        notificationTokenKeyboardWillShow = NotificationCenter
            .default
            .addObserver(forName: Notification.Name.UIKeyboardWillShow, object: nil, queue: OperationQueue.main) { [weak self] notification in
                
                if let userInfo = notification.userInfo, let frame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                    self?.buttonsBottomConstraint.constant = frame.height
                } else {
                    return
                }
                
        }
        
        notificationTokenKeyboardWillHide = NotificationCenter
            .default
            .addObserver(forName: Notification.Name.UIKeyboardWillHide, object: nil, queue: OperationQueue.main) { [weak self] notification in
                self?.buttonsBottomConstraint.constant = 0
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        loginRequest?.cancel()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(notificationTokenKeyboardWillShow!)
        NotificationCenter.default.removeObserver(notificationTokenKeyboardWillHide!)
    }
    
    // MARK: - Login API call -
    @IBAction func loginButtonTouched(_ sender: Any) {
        
        showProgressHud(messageToShow: "Logging in...")
        
        guard
            let email = emailTextField.text,
            let password = passwordTextField.text,
            !email.isEmpty,
            !password.isEmpty
            else {
                hideProgressHud()
                
                let title = "Invalid login data"
                let message = "Email and password are required"
                showAlertWithOK(with: title, message: message, nil)
                
                return
        }
        
        let params = [
            "data": [
                "type": "session",
                "attributes": [
                    "email": email,
                    "password": password
                ]
            ]
        ]
        
        loginRequest = Alamofire
            .request(
                "https://pokeapi.infinum.co/api/v1/users/login",
                method: .post,
                parameters: params)
            .validate()
            .responseDecodableObject { (response: DataResponse<UserModel>) in
                
                switch response.result {
                case .success:
                    self.hideProgressHud()
                    
                    UserDefaults.standard.set(email, forKey: UserDefaultsModel.email.rawValue)
                    UserDefaults.standard.set(password, forKey: UserDefaultsModel.password.rawValue)
                    
                    HomeViewController.switchToHomeScreen(self.navigationController, dataToInject: response.value!)
                    
                case .failure:
                    self.hideProgressHud()
                    
                    if let data = response.data {
                        let errorResponse = try? JSONDecoder().decode(ErrorModel.self, from: data)
                        
                        let title = "Invalid login data"
                        let message = errorResponse!.allErrorsAsString().trimmingCharacters(in: .whitespacesAndNewlines)
                        self.showAlertWithOK(with: title, message: message, nil)
                    }
                    
                    self.emailTextField.text = ""
                    self.passwordTextField.text = ""
                    
                }
                
        }
        
    }
    
    // MARK: - View switching -
    @IBAction func signUpButtonTouched(_ sender: Any) {
        
        let bundle = Bundle.main
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        let registerViewController = storyboard.instantiateViewController(
            withIdentifier: "RegisterViewController"
        )
        
        navigationController?.pushViewController(registerViewController, animated: true)
        
    }
    
}
