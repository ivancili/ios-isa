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
        }
        
        NotificationCenter
            .default
            .addObserver(forName: Notification.Name.UIKeyboardWillHide, object: nil, queue: OperationQueue.main) { notification in
                // keyboard is about to hide, handle UIScrollView contentInset, e.g.
                // scrollView.contentInset = UIEdgeInsetsMake(CGFloat, CGFloat, CGFloat, CGFloat)
        }
        
    }
    
    @IBAction func loginButtonTouched(_ sender: Any) {
        
        // Alamofire request
        // If success -> navigation to Home
        
        /*
         
         DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
         MBProgressHUD.showAdded(to: self.view, animated: true)
         }
         
         DispatchQueue.main.asyncAfter(deadline: .now() + 3 + 3) {
         MBProgressHUD.hide(for: self.view, animated: true)
         }
         
         */
        
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
                    let bundle = Bundle.main
                    let storyboard = UIStoryboard(name: "Main", bundle: bundle)
                    let homeViewController = storyboard.instantiateViewController(
                        withIdentifier: "HomeViewController"
                    )
                    self.navigationController?.setViewControllers([homeViewController], animated: true)
                case .failure(let error):
                    print("FAILURE: \(error.localizedDescription)")
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

