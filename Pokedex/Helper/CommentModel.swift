//
//  CommentModel.swift
//  Pokedex
//
//  Created by Infinum Student Academy on 30/07/2017.
//  Copyright © 2017 Ivan Ilic. All rights reserved.
//

import Foundation

struct CommentModel: Codable {
    
    var id: String
    var type: String
    
    struct CommentModelAttributes: Codable {
        let content: String
        let createdAt: String
        
        enum CodingKeys: String, CodingKey {
            case content
            case createdAt = "created-at"
        }
    }
    
    struct CommentModelRelationships: Codable {
        
        struct CommentModelAuthor: Codable {
            
            struct CommentModelData: Codable {
                let id: String
                let type: String
                
                enum CodingKeys: String, CodingKey {
                    case id
                    case type
                }
            }
            
            var data: CommentModelData
        }
        
        var author: CommentModelAuthor
    }
    
    var attributes: CommentModelAttributes
    var relationships: CommentModelRelationships
    
}
