//
//  HomeViewController.swift
//  Pokedex
//
//  Created by Infinum Student Academy on 15/07/2017.
//  Copyright © 2017 Ivan Ilic. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import CodableAlamofire

class HomeViewController: UIViewController {
    
    var data: UserModel?
    var pokemons: [PokemonModel]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard
            let auth = data?.authToken,
            let email = data?.email
            else { return }
        
        let headers: HTTPHeaders = [
            "Authorization": "Token token=\"\(auth)\", email=\"\(email)\"",
            "Content-Type": "application/json"
        ]
        
        Alamofire
            .request("https://pokeapi.infinum.co/api/v1/pokemons", method: .get, headers: headers)
            .validate()
            .responseDecodableObject(keyPath: "data") { (response: DataResponse<[PokemonModel]>) in
                
                switch response.result {
                case .success:
                    self.pokemons = response.value
                    print(response.result)
                    
                case .failure:
                    print(response.result)
                    
                    if let data = response.data {
                        let errorResponse = try? JSONDecoder().decode(ErrorModel.self, from: data)
                        print(errorResponse ?? "NOT DECODEABLE ERROR")
                    }
                    
                }
                
        }
        
    }
    
    private static func instantiate(dataToInject data: UserModel) -> HomeViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        vc.data = data
        return vc
    }
    
    public static func switchToHomeScreen(_ navigationController: UINavigationController?, dataToInject data: UserModel) -> Void {
        navigationController?.setViewControllers([HomeViewController.instantiate(dataToInject: data)], animated: true)
    }
    
}
