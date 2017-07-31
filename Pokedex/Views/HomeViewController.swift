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
    private var rc = UIRefreshControl()
    private var customRefreshView = UIImageView()
    
    private var user: UserModel?
    private var pokemons: [PokemonModel] = []
    
    private var notificationTokenFromPokemonUpload: NSObjectProtocol?
    private var pokemonFetchRequest: DataRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchListOfPokemons()
        navigationBarSetup()
        refreshControlSetup()
        notifyOfNewPokemon()
        
        // Table row height
        tableView.rowHeight = view.frame.size.height / 10
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
    
    // MARK: - New pokemon uploaded -
    func notifyOfNewPokemon() {
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
    }
    
    // MARK: - UIRefresh setup -
    func refreshControlSetup() {
        tableView.refreshControl = rc
        
        rc.addTarget(self, action: #selector(HomeViewController.startTableRefresh), for: UIControlEvents.valueChanged)
        rc.backgroundColor = UIColor.oceanBlue().withAlphaComponent(1.0)
        rc.tintColor = UIColor.clear
        rc.addSubview(customRefreshView)
        rc.bounds.size.width = view.bounds.width
        
        customRefreshView.frame = rc.bounds
        customRefreshView.contentMode = .scaleAspectFit
        customRefreshView.backgroundColor = UIColor.clear
        customRefreshView.image = UIImage.init(named: "pokeball")
    }
    
    @objc func startTableRefresh() {
        
        tableView.reloadData()
        
        customRefreshView.frame.size.height = 60
        
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = Double.pi * 2
        rotation.duration = 1
        rotation.speed = 10
        rotation.isCumulative = true
        rotation.repeatCount = .greatestFiniteMagnitude
        
        customRefreshView.layer.add(rotation, forKey: "spin")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
            self.customRefreshView.layer.removeAnimation(forKey: "spin")
            
            UIView.animate(
                withDuration: 0.05,
                animations: { self.customRefreshView.frame.size.height = 0 },
                completion: { (success) in
                    if success { self.rc.endRefreshing() }
            })
            
        }
        
    }
    
    // MARK: - Nav bar setup -
    func navigationBarSetup() {
        let imageLeft = UIImage(named: "ic-logout")
        let leftButton = UIBarButtonItem(image: imageLeft, style: .done, target: self, action: #selector(HomeViewController.logoutUser))
        navigationItem.leftBarButtonItem = leftButton
        
        let imageRight = UIImage(named: "ic-plus")
        let rightButton = UIBarButtonItem(image: imageRight, style: .done, target: self, action: #selector(HomeViewController.goToNewPokemonScreen))
        navigationItem.rightBarButtonItem = rightButton
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let user = user else { return }
        PokemonDetailsViewController.switchToDetailsScreen(navigationController, user, pokemons[indexPath.row])
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
            let token = user?.authToken,
            let email = user?.email
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
            let token = user?.authToken,
            let email = user?.email
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
                    
                    let title = "Logout failed"
                    let message = "Please check your connection"
                    self.showAlertWithOK(with: title, message: message, nil)
                    
                }
        }
        
    }
    
    // MARK: - View switching -
    @objc private func goToNewPokemonScreen() {
        AddNewPokemonViewController.switchToAddNewPokemonScreen(self.navigationController, dataToInject: user!)
    }
    
    public static func switchToHomeScreen(_ navigationController: UINavigationController?, dataToInject user: UserModel) -> Void {
        navigationController?.setViewControllers([HomeViewController.instantiate(dataToInject: user)], animated: true)
    }
    
    private static func instantiate(dataToInject user: UserModel) -> HomeViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        vc.user = user
        return vc
    }
    
}
