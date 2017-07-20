//
//  APIError.swift
//  Pokedex
//
//  Created by Infinum Student Academy on 20/07/2017.
//  Copyright © 2017 Ivan Ilic. All rights reserved.
//

import Foundation

struct JSONError: Codable, Error {
    let errors: [APIError]
}

struct APIError: Codable, Equatable {
    
    let detail: String?
    
    static func ==(lhs: APIError, rhs: APIError) -> Bool {
        return lhs.detail == rhs.detail
    }
    
}
