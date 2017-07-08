//
//  LoginViewController.swift
//  Pokedex
//
//  Created by Infinum Student Academy on 08/07/2017.
//  Copyright © 2017 Ivan Ilic. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButtonTouched(_ sender: Any) {
        
        guard
            let user = username.text,
            let pass = password.text,
            !user.isEmpty,
            !pass.isEmpty
        else {
            return print("Incorrect input")
        }
        
        print(user + ", " + pass)
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
