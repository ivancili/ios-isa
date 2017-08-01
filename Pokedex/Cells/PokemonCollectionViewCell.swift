//
//  PokemonCollectionViewCell.swift
//  Pokedex
//
//  Created by Infinum Student Academy on 31/07/2017.
//  Copyright © 2017 Ivan Ilic. All rights reserved.
//

import UIKit

class PokemonCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var pokemonImage: UIImageView!
    @IBOutlet weak var nameAndDateLabel: UILabel!
    @IBOutlet weak var upvoteCountLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        nameAndDateLabel.numberOfLines = 0
        nameAndDateLabel.lineBreakMode = .byWordWrapping
        
        contentView.layer.borderWidth = 0.1
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        
        pokemonImage.layer.cornerRadius = (pokemonImage.frame.size.width) / 2
        pokemonImage.clipsToBounds = true
        pokemonImage.contentMode = .scaleAspectFill
        pokemonImage.layer.borderWidth = 0.4
        pokemonImage.layer.borderColor = UIColor.oceanBlue().withAlphaComponent(1.0).cgColor
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        pokemonImage.image = nil
        nameAndDateLabel.text = ""
        upvoteCountLabel.text = ""
    }

    func configureCell(with pokemon: PokemonModel) {
        
        pokemonImage.image = nil
        nameAndDateLabel.text = ""
        upvoteCountLabel.text = ""
        
        let name = pokemon.attributes.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let date = pokemon.attributes.createdAt.lowercased().split(separator: "t").first?.description
        let upvoteCount = pokemon.attributes.votedOn

        var countLabelColor: UIColor = upvoteCountLabel.textColor
        
        if upvoteCount < 0 {
            countLabelColor = UIColor.red
        } else if upvoteCount > 0 {
            countLabelColor = UIColor.green
        }
        
        upvoteCountLabel.text = String(upvoteCount)
        upvoteCountLabel.textColor = countLabelColor
        nameAndDateLabel.text = name + "\n" + "Created on: " + date!

        if let imageURL = pokemon.attributes.imageURL {
            
            if let resource = URL.init(string: "https://pokeapi.infinum.co/" + imageURL) {
                
                // let compress = Compressor()
                // .processor(compress)
                
                pokemonImage.kf.setImage(
                    with: resource,
                    placeholder: UIImage.init(named: "ic-person"),
                    options: [],
                    progressBlock: nil,
                    completionHandler: nil
                )
                
            }
            
        }
        
    }


}
