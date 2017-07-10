//
//  ImageService.swift
//  RxService
//
//  Created by DragonCherry on 7/5/17.
//

import RxSwift
import RxCocoa
import AlamofireImage

public protocol ImageService {
    func image(fromUrl url: URL, placeholder: UIImage, reachabilityService service: ReachabilityService?) -> Observable<UIImage>
}

public enum ImageError: Error {
    case formatError
}

open class DefaultImageService: ImageService {
    
    open static let `default`: ImageService = {
        return DefaultImageService()
    }()
    
    private let imageCache: AutoPurgingImageCache
    
    private init(memoryCapacity: UInt64 = 10 * 1024 * 1024) {
        imageCache = AutoPurgingImageCache(memoryCapacity: memoryCapacity, preferredMemoryUsageAfterPurge: memoryCapacity / 2)
    }
    
    private func decodeImage(imageData data: Data) -> Observable<UIImage> {
        return Observable.just(data)
            .observeOn(SharedScheduler.backgroundScheduler)
            .map { data in
                guard let image = UIImage(data: data) else {
                    throw ImageError.formatError
                }
                return image.forceLazyImageDecompression()
        }
    }
    
    private func _image(fromUrl url: URL, placeholder: UIImage) -> Observable<UIImage> {
        
        return Observable.deferred {
            
                let decodedImage: Observable<UIImage>
            
                if let image = self.imageCache.image(withIdentifier: url.absoluteString) {
                    decodedImage = Observable.just(image)
                } else {
                    var request = URLRequest(url: url)
                    request.cachePolicy = .reloadIgnoringLocalCacheData
                    decodedImage = URLSession.shared.rx.data(request: request)
                        .asObservable()
                        .observeOn(SharedScheduler.backgroundScheduler)
                        .map { (data) in
                            if let image = UIImage(data: data) {
                                self.imageCache.add(image, withIdentifier: url.absoluteString)
                                return image
                            } else {
                                return placeholder
                            }
                        }
                        .observeOn(MainScheduler.instance)
                }
                return decodedImage
            }
    }
    
    public func image(fromUrl url: URL, placeholder: UIImage, reachabilityService: ReachabilityService?) -> Observable<UIImage> {
        if let reachabilityService = reachabilityService {
            return _image(fromUrl: url, placeholder: placeholder)
                .retryOnBecomesReachable(placeholder, reachabilityService: reachabilityService)
                .startWith(placeholder)
        } else {
            return _image(fromUrl: url, placeholder: placeholder)
                .startWith(placeholder)
        }
    }
}


