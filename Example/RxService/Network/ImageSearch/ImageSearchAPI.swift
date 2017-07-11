//
//  ImageSearchAPI.swift
//  RxService_Example
//
//  Created by DragonCherry on 7/10/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import RxSwift
import RxCocoa
import RxAlamofire
import RxService
import Alamofire
import ObjectMapper
import SwiftyJSON
import TinyLog

let kClientIdHeader: String             = "X-Naver-Client-Id"
let kClientId: String                   = "BLNZ7_JifgqMi3a_BG_t"
let kClientPasswordHeader: String       = "X-Naver-Client-Secret"
let kClientPassword: String             = "y1sSaAmmfz"

let kSearchURL: String                  = "https://openapi.naver.com/v1/search/image.json"

protocol ImageSearchAPI {
    static var `default`: ImageSearchAPI { get }
    func search(query: String, start: Int) -> Observable<[ImageSearchResult]>
}

class DefaultImageSearchAPI: ImageSearchAPI {
    
    private let kSearchLimit: Int = 10
    
    static var `default`: ImageSearchAPI = { return DefaultImageSearchAPI() }()
    
    func search(query: String, start: Int) -> Observable<[ImageSearchResult]> {
        
        log("Query: \(query)")
        let reachabilityService = try! DefaultReachabilityService.shared()
        
        let parameters: [String: Any] = [
            "query": query,
            "display": kSearchLimit + 1,
            "start": start,
            "sort": "sim"
        ]
        let headers = [
            kClientIdHeader: kClientId,
            kClientPasswordHeader: kClientPassword
        ]
        return request(.get, kSearchURL, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .flatMap { $0.validate(statusCode: 200..<300).rx.json() }
            .map { Mapper<ImageSearchResult>().mapArray(JSONObject: JSON($0)["items"].arrayObject) ?? [] }
            .retryOnBecomesReachable([], reachabilityService: reachabilityService)
            .observeOn(MainScheduler.instance)
    }
}
