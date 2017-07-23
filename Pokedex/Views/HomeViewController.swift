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

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, Alertable, Progressable {
    
    @IBOutlet weak var tableView: UITableView! { didSet {
        tableView.delegate = self
        tableView.dataSource = self
        }
    }
    
    var data: UserModel?
    var pokemons: [PokemonModel]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchListOfPokemons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
        
        let leftButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ic-logout"), style: .done, target: self, action: #selector(HomeViewController.logoutUser))
        self.navigationItem.leftBarButtonItem = leftButton
        
        let rightButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ic-add"), style: .done, target: self, action: #selector(HomeViewController.switchToNewPokemonScreen))
        self.navigationItem.rightBarButtonItem = rightButton
        
    }
    
    // MARK: - Table setup -
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pokemons?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PokemonTableViewCell = tableView.dequeueReusableCell(withIdentifier: "PokemonTableViewCell", for: indexPath) as! PokemonTableViewCell
        
        let name = pokemons?[indexPath.row].attributes.name
        cell.pokemonNameLabel?.text = name
        
        return cell
    }
    
    // MARK: - Helper -
    private static func instantiate(dataToInject data: UserModel) -> HomeViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        vc.data = data
        return vc
    }
    
    public static func switchToHomeScreen(_ navigationController: UINavigationController?, dataToInject data: UserModel) -> Void {
        navigationController?.setViewControllers([HomeViewController.instantiate(dataToInject: data)], animated: true)
    }
    
    // MARK: - API requests -
    private func fetchListOfPokemons() {
        
        guard
            let token = data?.authToken,
            let email = data?.email
            else { return }
        
        let headers: HTTPHeaders = [
            "Authorization": "Token token=\"\(token)\", email=\"\(email)\"",
            "Content-Type": "application/json"
        ]
        
        Alamofire
            .request("https://pokeapi.infinum.co/api/v1/pokemons", method: .get, headers: headers)
            .validate()
            .responseDecodableObject(keyPath: "data") { (response: DataResponse<[PokemonModel]>) in
                
                switch response.result {
                case .success:
                    print(response.result)
                    
                    self.pokemons = response.value
                    self.tableView.reloadData()
                    
                case .failure:
                    print(response.result)
                    
                    if let data = response.data {
                        let errorResponse = try? JSONDecoder().decode(ErrorModel.self, from: data)
                        print(errorResponse ?? "NOT DECODEABLE ERROR")
                    }
                    
                }
        }
        
    }
    
    @objc private func logoutUser() {
        
        guard
            let token = data?.authToken,
            let email = data?.email
            else { return }
        
        let headers: HTTPHeaders = [
            "Authorization": "Token token=\"\(token)\", email=\"\(email)\"",
            "Content-Type": "text/html"
        ]
        
        Alamofire
            .request("https://pokeapi.infinum.co/api/v1/users/logout", method: .delete, headers: headers)
            .validate()
            .responseJSON() { response in
                
                switch response.result {
                case .success:
                    print(response.result)
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                    let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
                    self.navigationController?.setViewControllers([loginViewController], animated: true)
                    
                case .failure:
                    print(response.result)
                    
                    if let data = response.data {
                        let errorResponse = try? JSONDecoder().decode(ErrorModel.self, from: data)
                        print(errorResponse ?? "NOT DECODEABLE ERROR")
                    }
                    
                }
        }
        
    }
    
    // MARK: - View switching -
    @objc private func switchToNewPokemonScreen() {
        
        
        
    }
    
}
