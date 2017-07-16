//
//  LoginViewController.swift
//  Pokedex
//
//  Created by Infinum Student Academy on 08/07/2017.
//  Copyright © 2017 Ivan Ilic. All rights reserved.
//

import UIKit
import MBProgressHUD
import CodableAlamofire
import Alamofire

class LoginViewController: UIViewController {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
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
    
    @IBAction func loginButtonTouched(_ sender: Any) {
        
        // Alamofire request
        // If success -> navigation to Home
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        guard
            let email = email.text,
            let password = password.text,
            !email.isEmpty,
            !password.isEmpty
            else {
                return print("Email and password are required.")
        }
        
        let params = [
            "data": [
                "type": "session",
                "attributes": [
                    "email": String(email),
                    "password": String(password)
                ]
            ]
        ]
        
        Alamofire
            .request(
                "https://pokeapi.infinum.co/api/v1/users/login",
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
    
    @IBAction func signUpButtonTouched(_ sender: Any) {
        
        let bundle = Bundle.main
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        let registerViewController = storyboard.instantiateViewController(
            withIdentifier: "RegisterViewController"
        )
        
        navigationController?.pushViewController(registerViewController, animated: true)
        
    }
}

