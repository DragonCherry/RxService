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
    func image(fromString urlString: String?, placeholder: UIImage?) -> Observable<UIImage>
    func image(fromUrl url: URL, placeholder: UIImage?) -> Observable<UIImage>
}

public enum ImageError: Error {
    case formatError
}

open class DefaultImageService: ImageService {
    
    open static let `default`: ImageService = {
        return DefaultImageService()
    }()
    
    private let imageCache: AutoPurgingImageCache
    private let reachabilityService = try? DefaultReachabilityService.shared()
    
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
    
    private func _image(fromUrl url: URL, placeholder: UIImage?) -> Observable<UIImage> {
        
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
                                return placeholder ?? UIImage()
                            }
                        }
                        .observeOn(MainScheduler.instance)
                }
                return decodedImage
            }
    }
    
    public func image(fromString urlString: String?, placeholder: UIImage?) -> Observable<UIImage> {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            return Observable.just(placeholder ?? UIImage())
        }
        return image(fromUrl: url, placeholder: placeholder)
    }
    
    public func image(fromUrl url: URL, placeholder: UIImage?) -> Observable<UIImage> {
        let alternative = placeholder ?? UIImage()
        if let reachabilityService = reachabilityService {
            return _image(fromUrl: url, placeholder: alternative)
                .retryOnBecomesReachable(alternative, reachabilityService: reachabilityService)
                .startWith(alternative)
        } else {
            return _image(fromUrl: url, placeholder: alternative)
                .startWith(alternative)
        }
    }
}



