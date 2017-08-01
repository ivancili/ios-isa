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

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, Alertable {
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.statusBarStyle = .lightContent
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.shared.statusBarStyle = .default
        pokemonFetchRequest?.cancel()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        animateCollectionView()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(notificationTokenFromPokemonUpload!)
        ImageCache.default.clearDiskCache()
        ImageCache.default.clearMemoryCache()
    }
    
    // MARK: - Setup methods -
    func refreshControlSetup() {
        collectionView.refreshControl = rc
        
        rc.addTarget(self, action: #selector(HomeViewController.startRefresh), for: UIControlEvents.valueChanged)
        rc.backgroundColor = UIColor.oceanBlue().withAlphaComponent(1.0)
        rc.tintColor = UIColor.clear
        rc.addSubview(customRefreshView)
        rc.bounds.size.width = view.bounds.width
        
        customRefreshView.frame = rc.bounds
        customRefreshView.contentMode = .scaleAspectFit
        customRefreshView.backgroundColor = UIColor.clear
        customRefreshView.image = UIImage.init(named: "pokeball")
    }
    
    @objc func startRefresh() {
        animateCollectionView()
        
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
    
    func navigationBarSetup() {
        let imageLeft = UIImage(named: "ic-logout")
        let leftButton = UIBarButtonItem(image: imageLeft, style: .done, target: self, action: #selector(HomeViewController.logoutUser))
        navigationItem.leftBarButtonItem = leftButton
        
        let imageRight = UIImage(named: "ic-plus")
        let rightButton = UIBarButtonItem(image: imageRight, style: .done, target: self, action: #selector(HomeViewController.goToNewPokemonScreen))
        navigationItem.rightBarButtonItem = rightButton
    }
    
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
                    self?.collectionView.reloadData()
                }
        )
    }
    
    // MARK: - Collection view setup -
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pokemons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PokemonCollectionViewCell", for: indexPath) as! PokemonCollectionViewCell
        
        let pokemon = pokemons[indexPath.row]
        cell.configureCell(with: pokemon)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellWidth = collectionView.frame.width
        let cellHeight = collectionView.frame.height / 6
        
        return CGSize.init(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let user = user else { return }
        
        PokemonDetailsViewController.switchToDetailsScreen(navigationController, user, pokemons[indexPath.row])
    }
    
    
    
    // MARK: - Animations -
    func animateCollectionView() {
        collectionView.reloadData()
        
        let updates: (()->(Void))? = { [weak self] in
            
            let cells = self?.collectionView.visibleCells
            
            for cell in cells! {
                cell.transform = CGAffineTransform.init(translationX: 0, y: (self?.view.bounds.height)!)
            }
            
            var counter = 0
            for cell in cells! {
                
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
        
        collectionView.performBatchUpdates(updates, completion: nil)
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
                    self.animateCollectionView()
                    
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
