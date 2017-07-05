//
//  ObservableType+Map.swift
//  RxService
//
//  Created by DragonCherry on 7/5/17.
//

import RxSwift
import ObjectMapper

enum MappingError: Error {
    case format
}

extension ObservableType {
    public func mapped<T: Mappable>() -> Observable<T> {
        return flatMap { data -> Observable<T> in
            guard let object = Mapper<T>().map(JSONObject: data) else {
                throw MappingError.format
            }
            return Observable.just(object)
        }
    }
    
    public func mappedArray<T: Mappable>() -> Observable<[T]> {
        return flatMap { data -> Observable<[T]> in
            guard let objects = Mapper<T>().mapArray(JSONObject: data) else {
                throw MappingError.format
            }
            return Observable.just(objects)
        }
    }
}

