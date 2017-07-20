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
    
    var data: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private static func instantiate(dataToInject data: User) -> HomeViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        vc.data = data
        return vc
    }
    
    public static func switchToHomeScreen(_ navigationController: UINavigationController?, dataToInject data: User) -> Void {
        navigationController?.setViewControllers([HomeViewController.instantiate(dataToInject: data)], animated: true)
    }
    
}
