//
//  ImageSearchResult.swift
//  RxService_Example
//
//  Created by DragonCherry on 7/10/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import ObjectMapper
import TinyLog

struct ImageSearchResult: Mappable {
    
    var title: String?
    var thumbnailUrl: String?
    var imageUrl: String?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        title <- map["title"]
        thumbnailUrl <- map["thumbnail"]
        imageUrl <- map["link"]
    }
}

