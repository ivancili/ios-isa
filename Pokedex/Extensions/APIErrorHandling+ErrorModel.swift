//
//  JSONErrorHandling+ErrorResponse.swift
//  Pokedex
//
//  Created by Infinum Student Academy on 20/07/2017.
//  Copyright © 2017 Ivan Ilic. All rights reserved.
//

import Foundation

extension ErrorModel {
    
    func allErrorsAsString() -> String {
        var data = ""
        
        for error in errors {
            data += (error.detail?.capitalized)!
            if errors.index(of: error) != errors.count {
                data += "\n"
            }
        }
        
        return data
    }
    
}
