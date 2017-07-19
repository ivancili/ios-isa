//
//  HomeViewController.swift
//  Pokedex
//
//  Created by Infinum Student Academy on 15/07/2017.
//  Copyright © 2017 Ivan Ilic. All rights reserved.
//

import UIKit
import Foundation

class HomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    public static func switchToHomeScreen(_ navigationController: UINavigationController?) -> Void {
        
        let bundle = Bundle.main
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        let homeViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController")
        
        navigationController?.setViewControllers([homeViewController], animated: true)
    }
    
}
