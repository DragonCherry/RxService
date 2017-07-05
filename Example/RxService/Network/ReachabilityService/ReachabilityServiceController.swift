//
//  ReachabilityServiceController.swift
//  RxService_Example
//
//  Created by DragonCherry on 7/5/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxService

class ReachabilityServiceController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    
    let disposeBag = DisposeBag()
    var reachabilityService: ReachabilityService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            reachabilityService = try RxReachabilityService()
            reachabilityService?.reachability
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { (status) in
                    switch status {
                    case .unreachable:
                        self.label.text = "Unreachable"
                    case .reachable(let viaWiFi):
                        self.label.text = viaWiFi ? "Reachable via WiFi" : "Reachable"
                    }
                })
                .disposed(by: disposeBag)
        } catch {
            label.text = "Error"
        }
    }
}
