//
//  AddNewPokemonViewController.swift
//  Pokedex
//
//  Created by Infinum Student Academy on 23/07/2017.
//  Copyright © 2017 Ivan Ilic. All rights reserved.
//

import UIKit
import Alamofire
import CodableAlamofire

let NotificationPokemonDidUpload = Notification.Name(rawValue: "NotificationPokemonDidUpload")
let NotificationPokemonValue = "NotificationPokemonValue"

class AddNewPokemonViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, Alertable, Progressable {
    
    private var data: UserModel?
    private let photoPicker = UIImagePickerController()
    
    private weak var notificationTokenKeyboardWillShow: NSObjectProtocol?
    private weak var notificationTokenKeyboardWillHide: NSObjectProtocol?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var abilitiesTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        photoPicker.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        notificationTokenKeyboardWillShow = NotificationCenter
            .default
            .addObserver(forName: Notification.Name.UIKeyboardWillShow, object: nil, queue: OperationQueue.main) { [weak self] notification in
                // keyboard is about to show
                guard
                    let userInfo = notification.userInfo,
                    let frame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
                        return
                }
                let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: frame.height, right: 0)
                self?.scrollView.contentInset = contentInset
        }
        
        notificationTokenKeyboardWillHide = NotificationCenter
            .default
            .addObserver(forName: Notification.Name.UIKeyboardWillHide, object: nil, queue: OperationQueue.main) { [weak self] notification in
                // keyboard is about to hide
                self?.scrollView.contentInset = UIEdgeInsets.zero
        }
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(notificationTokenKeyboardWillShow!)
        NotificationCenter.default.removeObserver(notificationTokenKeyboardWillHide!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - View switching -
    private func goToHomeScreen() {
        self.navigationController?.popViewController(animated: true)
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
    
    // MARK: - Image picker methods -
    @IBAction func addPhotoButtonTouched(_ sender: Any) {
        photoPicker.allowsEditing = false
        photoPicker.sourceType = .photoLibrary
        
        let title = "Access control"
        let message = "Allow Pokedex to access your photos?"
        
        let handleOK: ((UIAlertAction) -> Void)? = { [weak self] _ in
            self?.present((self?.photoPicker)!, animated: true)
        }
        
        showAlertWithCancelAndOK(with: title, message: message, handleOK, nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            imageView.contentMode = .scaleAspectFill
            imageView.image = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - API call handling -
    @IBAction func saveButtonTouched(_ sender: Any) {
        
        guard
            let token = data?.authToken,
            let email = data?.email
        else { return }
        
        let headers: HTTPHeaders = [
            "Authorization": "Token token=\"\(token)\", email=\"\(email)\"",
            "Content-Type": "text/html"
        ]
        
        /*
         guard
         let name = nameTextField.text,
         let height = heightTextField.text,
         let weight = weightTextField.text,
         let description = descriptionTextField.text,
         let image = imageView.image,
         !name.isEmpty,
         !height.isEmpty,
         !weight.isEmpty
         else { return }
         
         let attributes = [
         "name": name,
         "height": height,
         "weight": weight,
         "order": String(arc4random_uniform(50)),
         "is_default": (arc4random_uniform(2) == UInt32(1) ? String(true) : String(false)),
         "gender_id": String(arc4random_uniform(50)),
         "base_experience": String(arc4random_uniform(50)),
         "description": description
         ]
         */
        
        guard
            let image = imageView.image,
            let name = nameTextField.text,
            let description = descriptionTextField.text
        else {
            return
        }
        
        let attributes = [
            "name": name,
            "height": "30",
            "weight": "460",
            "order": "19",
            "is_default": "1",
            "gender_id": "1",
            "base_experience": "30",
            "description": description
        ]
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                
                multipartFormData.append(
                    UIImagePNGRepresentation(image)!,
                    withName: "data[attributes][image]",
                    fileName: "image.png",
                    mimeType: "image/png"
                )
                
                for (key, value) in attributes {
                    multipartFormData.append(
                        value.data(using: .utf8)!,
                        withName: "data[attributes][" + key + "]"
                    )
                }
                
        },
            to: "https://pokeapi.infinum.co/api/v1/pokemons",
            method: .post,
            headers: headers) { [weak self] result in
                
                switch result {
                case .success(let uploadRequest, _, _):
                    self?.processUploadRequest(uploadRequest)
                    
                case .failure:
                    self?.showAlertsOnUploadError()
                }
                
        }
        
    }
    
    private func processUploadRequest(_ uploadRequest: UploadRequest) {
        
        uploadRequest.responseDecodableObject(keyPath: "data") { (response: DataResponse<PokemonModel>) in
            switch response.result {
            case .success(let pokemon):
                print("DECODED: \(pokemon)")
                
                let notification = Notification(
                    name: NotificationPokemonDidUpload,
                    object: nil,
                    userInfo: [NotificationPokemonValue : pokemon]
                )
                NotificationCenter.default.post(notification)
                
                self.goToHomeScreen()
                
            case .failure(let error):
                print("FAILURE: \(error)")
                
                self.showAlertsOnUploadError()
            }
        }
        
    }
    
    // MARK: - Alert hadling -
    private func showAlertsOnUploadError() {
        
        let handleCancel: ((UIAlertAction) -> Void)? = { [weak self] _ in
            self?.goToHomeScreen()
        }
        let handleOK: ((UIAlertAction) -> Void)? = { [weak self] _ in
            self?.imageView.image = UIImage(named: "ic-person")
            self?.nameTextField.text = ""
            self?.nameTextField.text = ""
            self?.heightTextField.text = ""
            self?.weightTextField.text = ""
            self?.descriptionTextField.text = ""
        }
        
        let title = "Error while uploading data"
        let message = "Press OK to try again, press Cancel to go to home screen."
        self.showAlertWithCancelAndOK(with: title, message: message, handleOK, handleCancel)
        
    }
    
}
