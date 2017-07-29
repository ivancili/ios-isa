//
//  PokemonTableViewCell.swift
//  Pokedex
//
//  Created by Infinum Student Academy on 22/07/2017.
//  Copyright © 2017 Ivan Ilic. All rights reserved.
//

import UIKit
import Kingfisher

class PokemonTableViewCell: UITableViewCell {
    
    @IBOutlet weak var pokemonNameLabel: UILabel!
    @IBOutlet weak var pokemonImage: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.layer.borderWidth = 0.25
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        
        pokemonImage.layer.cornerRadius = (pokemonImage.frame.size.width)/2
        pokemonImage.clipsToBounds = true
        pokemonImage.contentMode = .scaleAspectFill
        pokemonImage.layer.borderWidth = 0.25
        pokemonImage.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        backgroundColor = UIColor.oceanBlue()
        let animation = {
            self.backgroundColor = UIColor.white
        }
        
        UIView.animate(
            withDuration: 0.25,
            delay: 0.1,
            options: .curveEaseOut,
            animations: animation,
            completion: nil
        )
        
    }
    
    func configureCell(with pokemon: PokemonModel) {
        
        pokemonImage.image = nil
        pokemonNameLabel.text = pokemon.attributes.name
        
        if let imageURL = pokemon.attributes.imageURL {
            
            if let resource = URL.init(string: "https://pokeapi.infinum.co/" + imageURL) {
                
                let processor = Compressor()
                
                pokemonImage.kf.setImage(
                    with: resource,
                    placeholder: UIImage.init(named: "ic-person"),
                    options: [ .transition(.fade(0.2)), .processor(processor)],
                    progressBlock: nil,
                    completionHandler: nil
                )
                
            }
            
        }
        
    }
    
}
