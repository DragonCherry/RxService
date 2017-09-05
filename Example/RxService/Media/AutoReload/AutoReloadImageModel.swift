//
//  AutoReloadImageAPI.swift
//  RxService_Example
//
//  Created by DragonCherry on 7/10/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import RxSwift
import RxCocoa

public enum AutoReloadImageError: Error {
    case invalidUrl
}

struct AutoReloadImageModel {
    
    var imageUrl: URL
    
    static func parseUrl(_ urlString: String) throws -> AutoReloadImageModel {
        if let imageUrl = URL(string: urlString) {
            return AutoReloadImageModel(imageUrl: imageUrl)
        } else {
            throw AutoReloadImageError.invalidUrl
        }
    }
}
