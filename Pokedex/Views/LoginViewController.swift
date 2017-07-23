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
        self.navigationController?.navigationBar.isHidden = true
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
                showAlert(with: title, message: message)
                
                return print("Email and password are required.")
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
        
        Alamofire
            .request(
                "https://pokeapi.infinum.co/api/v1/users/login",
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
                    
                    if let data = response.data {
                        let errorResponse = try? JSONDecoder().decode(ErrorModel.self, from: data)
                        
                        let title = "Invalid login data"
                        let message = errorResponse!.allErrorsAsString().trimmingCharacters(in: .whitespacesAndNewlines)
                        self.showAlert(with: title, message: message)
                    }
                    
                    self.emailTextField.text = ""
                    self.passwordTextField.text = ""
                    
                }
                
        }
        
    }
    
    @IBAction func signUpButtonTouched(_ sender: Any) {
        
        let bundle = Bundle.main
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        let registerViewController = storyboard.instantiateViewController(
            withIdentifier: "RegisterViewController"
        )
        
        navigationController?.pushViewController(registerViewController, animated: true)
        
    }
    
}
