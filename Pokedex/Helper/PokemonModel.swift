//
//  PokemonModel.swift
//  Pokedex
//
//  Created by Infinum Student Academy on 22/07/2017.
//  Copyright © 2017 Ivan Ilic. All rights reserved.
//

import Foundation

struct PokemonModel: Codable {
    
    var id: String
    var type: String
    
    struct PokemonModelAttributes: Codable {
        
        let name: String
        let baseExperience: Int?
        let isDefault: Bool
        let order: Int
        let height: Double
        let weight: Double
        let createdAt: String
        let updatedAt: String
        let imageURL: String?
        let description: String?
        let totalVoteCount: Int
        let votedOn: Int
        let gender: String
        
        enum CodingKeys: String, CodingKey {
            case name
            case baseExperience = "base-experience"
            case isDefault = "is-default"
            case order
            case height
            case weight
            case createdAt = "created-at"
            case updatedAt = "updated-at"
            case imageURL = "image-url"
            case description
            case totalVoteCount = "total-vote-count"
            case votedOn = "voted-on"
            case gender
        }
        
    }
    
    var attributes: PokemonModelAttributes
    
}
