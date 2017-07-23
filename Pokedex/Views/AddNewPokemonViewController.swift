//
//  AddNewPokemonViewController.swift
//  Pokedex
//
//  Created by Infinum Student Academy on 23/07/2017.
//  Copyright © 2017 Ivan Ilic. All rights reserved.
//

import UIKit

class AddNewPokemonViewController: UIViewController {
    
    private var data: UserModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    public static func switchToAddNewPokemonScreen(_ navigationController: UINavigationController?, dataToInject data: UserModel) -> Void {
        navigationController?.pushViewController(AddNewPokemonViewController.instantiate(dataToInject: data), animated: true)
    }
    
    private static func instantiate(dataToInject data: UserModel) -> AddNewPokemonViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: "AddNewPokemonViewController") as! AddNewPokemonViewController
        vc.data = data
        return vc
    }
    
}
