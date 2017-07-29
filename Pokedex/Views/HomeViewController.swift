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
import Kingfisher

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, Alertable, Progressable {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    // For animations
    private var viewLoadedForFirstTime = true
    
    private var data: UserModel?
    private var pokemons: [PokemonModel] = []
    private var notificationTokenFromPokemonUpload: NSObjectProtocol?
    private var pokemonFetchRequest: DataRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchListOfPokemons()
        
        notificationTokenFromPokemonUpload = NotificationCenter
            .default
            .addObserver(
                forName: NotificationPokemonDidUpload,
                object: nil,
                queue: nil,
                using: { [weak self] notification in
                    guard let newPokemon = notification.userInfo?[NotificationPokemonValue] as? PokemonModel else { return }
                    self?.pokemons.append(newPokemon)
                    self?.tableView.reloadData()
                }
        )
        
        let imageLeft = UIImage(named: "ic-logout")
        let leftButton = UIBarButtonItem(image: imageLeft, style: .done, target: self, action: #selector(HomeViewController.logoutUser))
        navigationItem.leftBarButtonItem = leftButton
        
        let imageRight = UIImage(named: "ic-plus")
        let rightButton = UIBarButtonItem(image: imageRight, style: .done, target: self, action: #selector(HomeViewController.goToNewPokemonScreen))
        navigationItem.rightBarButtonItem = rightButton
        
        // Table row height
        tableView.rowHeight = view.frame.size.height / 5
        
        // Image downloading setup
        ImageDownloader.default.downloadTimeout = 10
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pokemonFetchRequest?.cancel()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(notificationTokenFromPokemonUpload!)
        ImageCache.default.clearDiskCache()
        ImageCache.default.clearMemoryCache()
    }
    
    // MARK: - Table setup -
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pokemons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PokemonTableViewCell = tableView.dequeueReusableCell(withIdentifier: "PokemonTableViewCell", for: indexPath) as! PokemonTableViewCell
        
        let pokemon = pokemons[indexPath.row]
        cell.configureCell(with: pokemon)
        
        return cell
    }
    
    // MARK: - Animations -
    func animateTable() {
        
        tableView.reloadData()
        let cells = tableView.visibleCells
        
        for cell in cells {
            cell.transform = CGAffineTransform.init(translationX: 0, y: tableView.bounds.size.height)
        }
        
        var counter = 0
        for cell in cells {
            
            let animation = {
                cell.transform = CGAffineTransform.identity
            }
            
            UIView.animate(
                withDuration: 2,
                delay: Double(counter)*0.05,
                usingSpringWithDamping: 0.6,
                initialSpringVelocity: 0,
                options: .curveEaseOut,
                animations: animation,
                completion: nil
            )
            
            counter += 1
        }
        
    }
    
    // MARK: - API requests -
    private func fetchListOfPokemons() {
        
        guard
            let token = data?.authToken,
            let email = data?.email
            else {
                return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Token token=\"\(token)\", email=\"\(email)\"",
            "Content-Type": "application/json"
        ]
        
        pokemonFetchRequest = Alamofire
            .request("https://pokeapi.infinum.co/api/v1/pokemons", method: .get, headers: headers)
            .validate()
            .responseDecodableObject(keyPath: "data") { (response: DataResponse<[PokemonModel]>) in
                
                switch response.result {
                case .success:
                    self.pokemons = response.value!
                    self.animateTable()
                    
                case .failure:
                    
                    let title = "Error while loading Pokemons"
                    let message = "Press OK to try again, press Cancel to logout"
                    let handleOK: ((UIAlertAction)->())? = { [weak self] _ in
                        self?.fetchListOfPokemons()
                    }
                    let handleCancel: ((UIAlertAction)->())? = { [weak self] _ in
                        self?.logoutUser()
                    }
                    
                    self.showAlertWithCancelAndOK(with: title, message: message, handleOK, handleCancel)
                    
                }
        }
        
    }
    
    @objc private func logoutUser() {
        
        guard
            let token = data?.authToken,
            let email = data?.email
            else {
                return
        }
        
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
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                    let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
                    self.navigationController?.setViewControllers([loginViewController], animated: true)
                    
                case .failure:
                    
                    let title = "Something went wrong"
                    let message = "Please try again"
                    self.showAlertWithOK(with: title, message: message, nil)
                    
                }
        }
        
    }
    
    // MARK: - View switching -
    @objc private func goToNewPokemonScreen() {
        AddNewPokemonViewController.switchToAddNewPokemonScreen(self.navigationController, dataToInject: data!)
    }
    
    public static func switchToHomeScreen(_ navigationController: UINavigationController?, dataToInject data: UserModel) -> Void {
        navigationController?.setViewControllers([HomeViewController.instantiate(dataToInject: data)], animated: true)
    }
    
    private static func instantiate(dataToInject data: UserModel) -> HomeViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        vc.data = data
        return vc
    }
    
}
