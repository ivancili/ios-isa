//
//  Compression+ImageProcessor.swift
//  Pokedex
//
//  Created by Infinum Student Academy on 29/07/2017.
//  Copyright © 2017 Ivan Ilic. All rights reserved.
//

import Foundation
import Kingfisher
import UIKit

struct Compressor: ImageProcessor {
    
    var identifier: String = "com.ilic.compressor"
    
    func process(item: ImageProcessItem, options: KingfisherOptionsInfo) -> Image? {
        
        var image: UIImage? = nil
        
        switch item {
        case .image(let data):
            if let compressedData = UIImageJPEGRepresentation(data, 0.5) {
                image = UIImage.init(data: compressedData)
            }
        case .data:
            image = nil
        }
        
        return image
    }
    
}
