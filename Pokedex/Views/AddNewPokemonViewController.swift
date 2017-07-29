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
    private var photoPicker = UIImagePickerController()
    
    private weak var notificationTokenKeyboardWillShow: NSObjectProtocol?
    private weak var notificationTokenKeyboardWillHide: NSObjectProtocol?
    private weak var uploadNewPokemonRequest: DataRequest?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var saveButtonBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var abilitiesTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        photoPicker.delegate = self
        addImageButton.layer.cornerRadius = (addImageButton.frame.size.width) / 2
        addImageButton.clipsToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        notificationTokenKeyboardWillShow = NotificationCenter
            .default
            .addObserver(forName: Notification.Name.UIKeyboardWillShow, object: nil, queue: OperationQueue.main) { [weak self] notification in
                
                if let userInfo = notification.userInfo, let frame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                    self?.saveButtonBottomConstraint.constant = frame.height
                } else {
                    return
                }
                
        }
        
        notificationTokenKeyboardWillHide = NotificationCenter
            .default
            .addObserver(forName: Notification.Name.UIKeyboardWillHide, object: nil, queue: OperationQueue.main) { [weak self] notification in
                self?.saveButtonBottomConstraint.constant = 0
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        uploadNewPokemonRequest?.cancel()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(notificationTokenKeyboardWillShow!)
        NotificationCenter.default.removeObserver(notificationTokenKeyboardWillHide!)
    }
    
    // MARK: - View switching -
    private func goToHomeScreen() {
        navigationController?.popViewController(animated: true)
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
            else {
                return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Token token=\"\(token)\", email=\"\(email)\"",
            "Content-Type": "text/html"
        ]
        
        guard
            let image = imageView.image,
            let name = nameTextField.text,
            let height = heightTextField.text,
            let weight = weightTextField.text,
            let description = descriptionTextField.text
            else {
                showAlertsOnUploadError()
                return
        }
        
        let attributes = [
            "name": name,
            "height": height,
            "weight": weight,
            "is_default": String(arc4random_uniform(2)),
            "gender_id": String(arc4random_uniform(2)),
            "description": description
        ]
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                
                multipartFormData.append(
                    UIImageJPEGRepresentation(image, 0.5)!,
                    withName: "data[attributes][image]",
                    fileName: "image.jpeg",
                    mimeType: "image/jpeg"
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
        
        uploadNewPokemonRequest = uploadRequest.responseDecodableObject(keyPath: "data") { (response: DataResponse<PokemonModel>) in
            
            switch response.result {
            case .success(let pokemon):
                
                let notification = Notification(
                    name: NotificationPokemonDidUpload,
                    object: nil,
                    userInfo: [NotificationPokemonValue : pokemon]
                )
                NotificationCenter.default.post(notification)
                
                let title = "New Pokemon successfully created."
                self.showAlertWithOK(with: title, message: nil, { [weak self] _ in
                    self?.goToHomeScreen()
                })
                
            case .failure:
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
            self?.heightTextField.text = ""
            self?.weightTextField.text = ""
            self?.typeTextField.text = ""
            self?.abilitiesTextField.text = ""
            self?.descriptionTextField.text = ""
        }
        
        let title = "Error while uploading data"
        let message = "Press OK to try adding new pokemon again, press Cancel to go to home screen."
        showAlertWithCancelAndOK(with: title, message: message, handleOK, handleCancel)
        
    }
    
}
