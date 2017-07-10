//
//  AutoReloadImageViewModel.swift
//  RxService_Example
//
//  Created by DragonCherry on 7/5/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import RxSwift
import RxCocoa
import RxService
import RxSwiftExt
import TinyLog

class AutoReloadImageViewModel {
    
    var model: AutoReloadImageModel
    
    var image: Driver<UIImage>
    
    init(model: AutoReloadImageModel) {
        self.model = model
        self.image = Driver.never()
        self.image = configureImage().asDriver(onErrorJustReturn: Resource.commonPlaceholder)
    }
    
    func configureImage() -> Observable<UIImage> {
        var reachabilityService: ReachabilityService?
        do {
            reachabilityService = try DefaultReachabilityService.shared()
        } catch {
            logw("\(error)")
        }
        return DefaultImageService.default.image(fromUrl: model.imageUrl, placeholder: Resource.commonPlaceholder, reachabilityService: reachabilityService)
            .shareReplayLatestWhileConnected()
    }
}
