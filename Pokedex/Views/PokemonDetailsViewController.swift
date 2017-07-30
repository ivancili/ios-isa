//
//  PokemonDetailsViewController.swift
//  Pokedex
//
//  Created by Infinum Student Academy on 29/07/2017.
//  Copyright © 2017 Ivan Ilic. All rights reserved.
//

import UIKit
import Alamofire
import CodableAlamofire
import Kingfisher

class PokemonDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var user: UserModel?
    private var pokemon: PokemonModel?
    private var comments: [String] = []
    
    private weak var notificationTokenKeyboardWillShow: NSObjectProtocol?
    private weak var notificationTokenKeyboardWillHide: NSObjectProtocol?
    
    @IBOutlet weak var bottomScrollViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var commenstTableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var pokemonImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var abilitiesLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var newCommentLabel: UILabel!
    
    @IBOutlet weak var commentsTableView: UITableView! {
        didSet {
            commentsTableView.delegate = self
            commentsTableView.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        fillTheDetailsTemplate()
        loadCommentsOverAPI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Table row height
        commentsTableView.rowHeight = view.frame.size.height / 10
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        notificationTokenKeyboardWillShow = NotificationCenter
            .default
            .addObserver(forName: Notification.Name.UIKeyboardWillShow, object: nil, queue: OperationQueue.main) { [weak self] notification in
                
                if let userInfo = notification.userInfo, let frame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                    self?.bottomScrollViewConstraint.constant = frame.height
                } else {
                    return
                }
                
        }
        
        notificationTokenKeyboardWillHide = NotificationCenter
            .default
            .addObserver(forName: Notification.Name.UIKeyboardWillHide, object: nil, queue: OperationQueue.main) { [weak self] notification in
                self?.bottomScrollViewConstraint.constant = 0
        }

    }
    
    deinit {
        NotificationCenter.default.removeObserver(notificationTokenKeyboardWillShow!)
        NotificationCenter.default.removeObserver(notificationTokenKeyboardWillHide!)
    }
    
    // MARK: - Navigation bar setup -
    func setupNavigationBar() {
        
        // left button
        let imageLeft = UIImage(named: "ic-back")
        let leftButtonSelector: Selector? = #selector(PokemonDetailsViewController.goToHomeScreen)
        let leftButton = UIBarButtonItem(image: imageLeft, style: .done, target: self, action: leftButtonSelector)
        
        navigationItem.leftBarButtonItem = leftButton
        
        // right buttons
        var rightButtons: [UIBarButtonItem] = []
        
        let firstImageRight = UIImage(named: "ic-edit")
        rightButtons.append(UIBarButtonItem(image: firstImageRight, style: .done, target: self, action: nil))
        
        let secondImageRight = UIImage(named: "ic-info")
        rightButtons.append(UIBarButtonItem(image: secondImageRight, style: .done, target: self, action: nil))
        
        navigationItem.rightBarButtonItems = rightButtons
    }
    
    // MARK: - Pokemon details presentation -
    func fillTheDetailsTemplate() {
        
        guard let pokemon = pokemon else {
            return
        }
        
        pokemonImage.image = nil
        if let imageURL = pokemon.attributes.imageURL {
            if let resource = URL.init(string: "https://pokeapi.infinum.co/" + imageURL) {
                pokemonImage.kf.setImage(
                    with: resource,
                    placeholder: UIImage.init(named: "ic-person"),
                    options: [],
                    progressBlock: nil,
                    completionHandler: nil
                )
            }
        }
        
        nameLabel.text = pokemon.attributes.name
        descriptionLabel.text = pokemon.attributes.description
        heightLabel.text = String(pokemon.attributes.height)
        abilitiesLabel.text = "Empty"
        weightLabel.text = String(pokemon.attributes.weight)
        typeLabel.text = "Empty"
        genderLabel.text = pokemon.attributes.gender.uppercased()
    }
    
    // MARK: - API requests -
    func loadCommentsOverAPI() {
        // todo
        // animate height constraint
        // get comments based on pokemon id
        // get author based on used id
    }
    
    // MARK: - Table view setup -
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CommentTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell", for: indexPath) as! CommentTableViewCell
        
        let comment = comments[indexPath.row]
        let username = ""
        
        cell.configure(username, comment)
        
        return cell
    }
    
    // MARK: - Comment handling -
    @IBAction func addCommentButtonTouched(_ sender: Any) {
    }
    
    // MARK: - View switching -
    public static func switchToDetailsScreen(_ navigationController: UINavigationController?, _ user: UserModel, _ pokemon: PokemonModel) -> Void {
        navigationController?.pushViewController(PokemonDetailsViewController.instantiate(user, pokemon), animated: true)
    }
    
    private static func instantiate(_ user: UserModel, _ pokemon: PokemonModel) -> PokemonDetailsViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: "PokemonDetailsViewController") as! PokemonDetailsViewController
        vc.user = user
        vc.pokemon = pokemon
        return vc
    }
    
    @objc private func goToHomeScreen() {
        navigationController?.popViewController(animated: true)
    }
    
}
