//
//  AddNewPokemonViewController.swift
//  Pokedex
//
//  Created by Infinum Student Academy on 23/07/2017.
//  Copyright © 2017 Ivan Ilic. All rights reserved.
//

import UIKit

class AddNewPokemonViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private var data: UserModel?
    private let photoPicker = UIImagePickerController()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var abilitiesTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoPicker.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - View switching -
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
        
        present(photoPicker, animated: true, completion: nil)
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
    }
}
