//
//  AutoReloadImageController.swift
//  RxService_Example
//
//  Created by DragonCherry on 7/5/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxService
import TinyLog
import SwiftARGB

class AutoReloadImageController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    let disposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTextField()
    }
    
    func configureTextField() {
        
        let result = textField.rx.text.orEmpty
            .asDriver()
            .throttle(0.3)
            .distinctUntilChanged()
            .flatMapLatest { (urlString) in
                Observable.just(urlString).asDriver(onErrorJustReturn: "")
            }
            .map { URL(string: $0) }
            .filter { $0 != nil }
            .map { AutoReloadImageModel(imageUrl: $0!) }
            .map(AutoReloadImageViewModel.init)
        
        result.drive(onNext: { [weak self] (viewModel) in
            if let imageView = self?.imageView, let disposeBag = self?.disposeBag {
                viewModel.image.drive(imageView.rx.image)
                    .disposed(by: disposeBag)
            }
        }).disposed(by: disposeBag)
        
        let gesture = UITapGestureRecognizer()
        gesture.rx.event
            .subscribe(onNext: { [weak self] _ in
                self?.textField.endEditing(true)
            })
            .disposed(by: disposeBag)
        view.addGestureRecognizer(gesture)
    }
    
    deinit {
        logd("Released \(type(of: self))")
    }
}

