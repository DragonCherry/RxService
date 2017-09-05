//
//  SharedScheduler.swift
//  RxService
//
//  Created by DragonCherry on 7/5/17.
//

import RxSwift

open class SharedScheduler {
    
    static open var backgroundScheduler: ImmediateSchedulerType = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 2
        operationQueue.qualityOfService = QualityOfService.userInitiated
        return OperationQueueScheduler(operationQueue: operationQueue)
    }()
}
