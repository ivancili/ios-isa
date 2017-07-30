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

let commentCellHeight = 75
class PokemonDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, Alertable {
    
    private var user: UserModel?
    private var pokemon: PokemonModel?
    private var comments: [CommentModel] = []
    private var users: [UserDataModel] = []
    
    private weak var notificationTokenKeyboardWillShow: NSObjectProtocol?
    private weak var notificationTokenKeyboardWillHide: NSObjectProtocol?
    
    private weak var commentsFetchRequest: DataRequest?
    private weak var usersFetchRequest: DataRequest?
    private weak var commentUploadRequest: DataRequest?
    
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
    @IBOutlet weak var newCommentTextField: UITextField!
    
    @IBOutlet weak var commentsTableView: UITableView! {
        didSet {
            commentsTableView.delegate = self
            commentsTableView.dataSource = self
            commentsTableView.separatorStyle = UITableViewCellSeparatorStyle.none
            commentsTableView.allowsSelection = false
            commentsTableView.rowHeight = CGFloat.init(commentCellHeight)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        setupNavigationBar()
        fillTheDetailsTemplate()
        loadCommentsOverAPI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Screen title
        title = pokemon?.attributes.name.capitalized
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        commentsFetchRequest?.cancel()
        usersFetchRequest?.cancel()
        commentUploadRequest?.cancel()
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
        
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.numberOfLines = 0
        descriptionLabel.text = pokemon.attributes.description
        
        heightLabel.text = String(pokemon.attributes.height)
        abilitiesLabel.text = "Empty"
        weightLabel.text = String(pokemon.attributes.weight)
        typeLabel.text = "Empty"
        genderLabel.text = pokemon.attributes.gender.uppercased()
    }
    
    // MARK: - API requests -
    func loadCommentsOverAPI() {
        
        guard
            let token = user?.authToken,
            let email = user?.email,
            let pokemonID = pokemon?.id
            else { return }
        
        let headers: HTTPHeaders = [
            "Authorization": "Token token=\(token), email=\(email)",
            "Content-Type": "application/json"
        ]
        
        commentsFetchRequest = Alamofire
            .request(
                "https://pokeapi.infinum.co/api/v1/pokemons/\(pokemonID)/comments",
                method: .get,
                headers: headers)
            .validate()
            .responseDecodableObject(keyPath: "data") { (response: DataResponse<[CommentModel]>) in
                
                switch response.result {
                case .success:
                    self.comments = response.value!
                    self.loadUserDatabaseOverAPI()
                    
                case .failure:
                    
                    let title = "Error while loading comments"
                    let message = "Check your connection"
                    self.showAlertWithOK(with: title, message: message, { (_) in
                        self.goToHomeScreen()
                    })
                    
                }
                
        }
        
    }
    
    func loadUserDatabaseOverAPI() {
        
        guard
            let token = user?.authToken,
            let email = user?.email
            else { return }
        
        let headers: HTTPHeaders = [
            "Authorization": "Token token=\(token), email=\(email)",
            "Content-Type": "application/json"
        ]
        
        for comment in comments {
            
            let authorID = comment.relationships.author.data.id
            
            Alamofire
                .request(
                    "https://pokeapi.infinum.co/api/v1/users/\(authorID)",
                    method: .get,
                    headers: headers)
                .validate()
                .responseDecodableObject(keyPath: "data") { (response: DataResponse<UserDataModel>) in
                    
                    switch response.result {
                    case .success(let user):
                        self.commentsTableView.reloadData()
                        self.users.append(user)
                        
                    case .failure:
                        
                        let title = "Error while loading comments."
                        self.showAlertWithOK(with: title, message: nil, { (_) in
                            self.goToHomeScreen()
                        })
                        
                    }
                    
            }
            
        }
        
        self.animateCommentsTable()
        
    }
    
    @IBAction func addCommentButtonTouched(_ sender: Any) {
        
        guard
            let token = user?.authToken,
            let email = user?.email,
            let comment = newCommentTextField.text,
            let pokemonID = pokemon?.id,
            !comment.isEmpty
            else { return }
        
        let headers: HTTPHeaders = [
            "Authorization": "Token token=\(token), email=\(email)",
            "Content-Type": "application/json"
        ]
        
        Alamofire.upload(
            multipartFormData: { (multipartFormData) in
                
                multipartFormData.append(
                    comment.data(using: .utf8)!,
                    withName: "data[attributes][content]"
                )
                
        },
            to: "https://pokeapi.infinum.co/api/v1/pokemons/\(pokemonID)/comments",
            method: .post,
            headers: headers) { [weak self] result in
                
                switch result {
                case .success(let uploadRequest, _, _):
                    self?.processUploadRequest(uploadRequest)
                    
                case .failure(let error):
                    print(error)
                }
                
        }
        
        
    }
    
    private func processUploadRequest(_ uploadRequest: UploadRequest) {
        
        commentUploadRequest = uploadRequest.responseDecodableObject(keyPath: "data") { (response: DataResponse<CommentModel>) in
            
            switch response.result {
            case .success:
                self.comments.append(response.value!)
                self.newCommentTextField.text = ""
                self.animateCommentsTable()
                
            case .failure(let error):
                print(error)
                
            }
            
        }
        
    }
    
    // MARK: - Table view setup -
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CommentTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell", for: indexPath) as! CommentTableViewCell
        
        let comment = comments[indexPath.row]
        let user = linkUserWithComment(comment)
        
        cell.configure(user, comment)
        
        return cell
    }
    
    // MARK: - Linking user and comment -
    func linkUserWithComment(_ comment: CommentModel) -> UserDataModel? {
        for user in users {
            if user.id == comment.relationships.author.data.id {
                return user
            }
        }
        return nil
    }
    
    // MARK: - Comments table animation -
    func animateCommentsTable() {
        UIView.animate(withDuration: 1, animations: {
            self.commentsTableView.reloadData()
            self.commenstTableViewHeightConstraint.constant = CGFloat.init(self.comments.count * commentCellHeight)
        })
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
