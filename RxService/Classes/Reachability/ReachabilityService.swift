//
//  ReachabilityService.swift
//
//  Created by Vodovozov Gleb on 10/22/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import ReachabilitySwift

// MARK: - ReachabilityStatus
public enum ReachabilityStatus {
    case reachable(viaWiFi: Bool)
    case unreachable
}

// MARK: - extension ReachabilityStatus
public extension ReachabilityStatus {
    var reachable: Bool {
        switch self {
        case .reachable:
            return true
        case .unreachable:
            return false
        }
    }
}

// MARK: - ReachabilityService
public protocol ReachabilityService {
    var reachability: Observable<ReachabilityStatus> { get }
}

// MARK: - ReachabilityServiceError
public enum ReachabilityServiceError: Error {
    case failedToCreate
}

// MARK: - RxReachabilityService
open class RxReachabilityService: ReachabilityService {
    
    private let _reachabilitySubject: BehaviorSubject<ReachabilityStatus>
    
    open var reachability: Observable<ReachabilityStatus> {
        return _reachabilitySubject.asObservable()
    }
    
    private let _reachability: Reachability
    
    public init() throws {
        guard let reachabilityRef = Reachability() else { throw ReachabilityServiceError.failedToCreate }
        let reachabilitySubject = BehaviorSubject<ReachabilityStatus>(value: .unreachable)
        
        // so main thread isn't blocked when reachability via WiFi is checked
        let backgroundQueue = DispatchQueue(label: "reachability.wificheck")
        
        reachabilityRef.whenReachable = { reachability in
            backgroundQueue.async {
                reachabilitySubject.on(.next(.reachable(viaWiFi: reachabilityRef.isReachableViaWiFi)))
            }
        }
        
        reachabilityRef.whenUnreachable = { reachability in
            backgroundQueue.async {
                reachabilitySubject.on(.next(.unreachable))
            }
        }
        
        try reachabilityRef.startNotifier()
        _reachability = reachabilityRef
        _reachabilitySubject = reachabilitySubject
    }
    
    deinit { _reachability.stopNotifier() }
}

extension ObservableConvertibleType {
    public func retryOnBecomesReachable(_ valueOnFailure: E, reachabilityService: ReachabilityService) -> Observable<E> {
        return self.asObservable()
            .catchError { (e) -> Observable<E> in
                reachabilityService.reachability
                    .skip(1)
                    .filter { $0.reachable }
                    .flatMap { _ in
                        Observable.error(e)
                    }
                    .startWith(valueOnFailure)
            }
            .retry()
    }
}

