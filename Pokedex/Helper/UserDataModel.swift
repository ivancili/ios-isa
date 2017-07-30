//
//  UserDataModel.swift
//  Pokedex
//
//  Created by Infinum Student Academy on 30/07/2017.
//  Copyright © 2017 Ivan Ilic. All rights reserved.
//

import Foundation

struct UserDataModel: Codable {
    
    var id: String
    var type: String
    
    struct UserDataAttributes: Codable {
        let email: String
        let username: String
        
        enum CodingKeys: String, CodingKey {
            case email
            case username
        }
    }
    
    var attributes: UserDataAttributes
}
