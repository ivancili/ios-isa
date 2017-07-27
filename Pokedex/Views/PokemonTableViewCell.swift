//
//  PokemonTableViewCell.swift
//  Pokedex
//
//  Created by Infinum Student Academy on 22/07/2017.
//  Copyright © 2017 Ivan Ilic. All rights reserved.
//

import UIKit

class PokemonTableViewCell: UITableViewCell {
    
    @IBOutlet weak var pokemonNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.borderWidth = 0.75
        self.contentView.layer.borderColor = (UIColor.lightGray).cgColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configureCell(with pokemon: PokemonModel) {
        pokemonNameLabel.text = pokemon.attributes.name
    }
    
}
