//
//  LoginViewController.swift
//  Pokedex
//
//  Created by Infinum Student Academy on 08/07/2017.
//  Copyright © 2017 Ivan Ilic. All rights reserved.
//

import UIKit
import MBProgressHUD

class LoginViewController: UIViewController {
    
    @IBOutlet weak var username: UITextField!
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
        
        /*
         
         DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
         MBProgressHUD.showAdded(to: self.view, animated: true)
         }
         
         DispatchQueue.main.asyncAfter(deadline: .now() + 3 + 3) {
         MBProgressHUD.hide(for: self.view, animated: true)
         }
         
         */
        
        guard
            let user = username.text,
            let pass = password.text,
            !user.isEmpty,
            !pass.isEmpty
            else {
                return print("Incorrect input")
        }
        print("USERNAME: " + user + "\t" + "PASSWORD: " + pass)
        
        
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
