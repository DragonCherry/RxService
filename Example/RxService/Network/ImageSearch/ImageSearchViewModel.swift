//
//  ImageSearchViewModel.swift
//  RxService_Example
//
//  Created by DragonCherry on 7/10/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import RxSwift
import RxCocoa
import RxService

class ImageSearchViewModel {
    
    var searchResult: ImageSearchResult
    
    var title: Driver<String>
    var image: Driver<UIImage>
    
    init(searchResult: ImageSearchResult) {
        
        self.searchResult = searchResult
        
        self.title = Driver.never()
        self.image = Driver.never()
        
        self.title = self.configureTitle(title: searchResult.title)
        self.image = self.configureImage(urlString: searchResult.imageUrl)
    }
    
    func configureTitle(title: String?) -> Driver<String> {
        return Observable.from(optional: title)
            .asDriver(onErrorJustReturn: "")
    }
    
    func configureImage(urlString: String?) -> Driver<UIImage> {
        return Observable.from(optional: urlString)
            .flatMap { Observable.from(optional: URL(string: $0)) }
            .flatMap { url in
                DefaultImageService.default.image(fromUrl: url, placeholder: Resource.commonPlaceholder, reachabilityService: try? DefaultReachabilityService.shared())
            }
            .asDriver(onErrorJustReturn: Resource.commonPlaceholder)
    }
}
