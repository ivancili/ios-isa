//
//  CustomParser+NSDate.swift
//  Pokedex
//
//  Created by Infinum Student Academy on 01/08/2017.
//  Copyright © 2017 Ivan Ilic. All rights reserved.
//

import Foundation

extension Date {
    
    public static func parsePokemonDate(_ date: String) -> Date {
        
        let date = date.lowercased().split(separator: "t").first?.description
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let parsedDate = dateFormatter.date(from: date!)
        
        return parsedDate!
    }
    
    public static func customDateToString(_ date: Date) -> String {
        
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "dd/MM/yyyy"
        let ddMMyyyy = dateFormatter.string(from: date)
        
        return ddMMyyyy
    }
    
}
