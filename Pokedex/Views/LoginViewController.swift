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

class LoginViewController: UIViewController, Progressable {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var pokeballImage: UIImageView!
    
    @IBOutlet weak var emailBorder: UIView!
    @IBOutlet weak var passwordBorder: UIView!
    
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
        (emailTextField.text, passwordTextField.text) = readUserDefaults()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        keyboardHandlingSetup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        loginRequest?.cancel()
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
    
    // MARK: - Animations -
    func spinThePokeball() {
        
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = Double.pi * 2
        rotation.duration = 1
        rotation.speed = 10
        rotation.isCumulative = true
        rotation.repeatCount = .greatestFiniteMagnitude
        
        pokeballImage.layer.add(rotation, forKey: "spin")
        
        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.toValue = 1.5
        scale.duration = 1
        
        pokeballImage.layer.add(scale, forKey: "scale")
    }
    
    func stopSpinningPokeball() {
        pokeballImage.layer.removeAnimation(forKey: "spin")
        pokeballImage.layer.removeAnimation(forKey: "scale")
    }
    
    func loginSuccessAnimation() {
        loginResultAnimation(withColor: UIColor.green)
    }
    
    func loginFailAnimation() {
        loginResultAnimation(withColor: UIColor.red)
        
        let animation: () -> Void = {
            self.pokeballImage.transform = CGAffineTransform.init(scaleX: 1.1, y: 1)
        }
        let completion: ((Bool) -> Void)? = { success in
            if success {
                UIView.animate(withDuration: 0.25, animations: {
                    self.pokeballImage.transform = CGAffineTransform.identity
                })
            }
        }
        
        UIView.animate(
            withDuration: 1,
            delay: 0,
            usingSpringWithDamping: 0.2,
            initialSpringVelocity: 10,
            options: .curveEaseInOut,
            animations: animation,
            completion: completion
        )
        
    }
    
    func loginResultAnimation(withColor color: UIColor) {
        
        let height = CGFloat.init(4)
        let alpha = CGFloat.init(0.75)
        let cgColor = color.withAlphaComponent(alpha).cgColor
        
        let animation: ((UIView)->(() -> Void)) = { view in
            return {
                view.layer.backgroundColor = UIColor.lightGray.cgColor;
                view.layer.bounds.size.height = 1
            }
        }
        
        loginBorderAnimationSetup(forBorder: emailBorder, withColor: cgColor, withHeight: height)
        UIView.animate(withDuration: 0.25, animations: animation(emailBorder)) { (_) in
            
            self.loginBorderAnimationSetup(forBorder: self.emailBorder, withColor: cgColor, withHeight: height)
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: animation(self.emailBorder), completion: nil)
        }
        
        loginBorderAnimationSetup(forBorder: passwordBorder, withColor: cgColor, withHeight: height)
        UIView.animate(withDuration: 0.25, animations: animation(passwordBorder)) { (_) in
            
            self.loginBorderAnimationSetup(forBorder: self.passwordBorder, withColor: cgColor, withHeight: height)
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: animation(self.passwordBorder), completion: nil)
        }
        
    }
    
    func loginBorderAnimationSetup(forBorder view: UIView, withColor color: CGColor, withHeight height: CGFloat) {
        view.layer.backgroundColor = color
        view.layer.bounds.size.height = height
    }
    
    // MARK: - Login API call -
    @IBAction func loginButtonTouched(_ sender: Any) {
        
        spinThePokeball()
        
        guard
            let email = emailTextField.text, let password = passwordTextField.text, !email.isEmpty, !password.isEmpty
        else {
            stopSpinningPokeball()
            loginFailAnimation()
            
            emailTextField.text = ""
            passwordTextField.text = ""
            
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
                    self.stopSpinningPokeball()
                    self.loginSuccessAnimation()
                    self.setUserDefaults(email: email, password: password)
                    
                    let when = DispatchTime.now() + 1
                    DispatchQueue.main.asyncAfter(deadline: when, execute: {
                        HomeViewController.switchToHomeScreen(self.navigationController, dataToInject: response.value!)
                    })
                    
                case .failure:
                    self.stopSpinningPokeball()
                    self.loginFailAnimation()
                    
                    self.emailTextField.text = ""
                    self.passwordTextField.text = ""
                    
                }
                
        }
        
    }
    
    // MARK: - UserDefaults handling -
    private func setUserDefaults(email userEmail: String, password userPassword: String) {
        UserDefaults.standard.set(userEmail, forKey: UserDefaultsModel.email.rawValue)
        UserDefaults.standard.set(userPassword, forKey: UserDefaultsModel.password.rawValue)
    }
    
    private func readUserDefaults() -> (String?, String?) {
        let email = UserDefaults.standard.value(forKey: UserDefaultsModel.email.rawValue) as? String
        let password = UserDefaults.standard.value(forKey: UserDefaultsModel.password.rawValue) as? String
        
        return (email, password)
    }
    
    // MARK: - Password entry visibility -
    @IBAction func passwordVisibilityActive(_ sender: Any) {
        passwordTextField.isSecureTextEntry = true
    }
    
    @IBAction func passwordVisibilityDisabled(_ sender: Any) {
        passwordTextField.isSecureTextEntry = false
    }
    
    // MARK: - View switching -
    @IBAction func signUpButtonTouched(_ sender: Any) {
        
        let bundle = Bundle.main
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        let registerViewController = storyboard.instantiateViewController(withIdentifier: "RegisterViewController")
        
        navigationController?.pushViewController(registerViewController, animated: true)
        
    }
    
}
