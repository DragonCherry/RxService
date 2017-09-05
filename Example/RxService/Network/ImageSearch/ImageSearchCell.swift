//
//  ImageSearchCell.swift
//  RxService_Example
//
//  Created by DragonCherry on 7/10/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import RxSwift
import RxCocoa
import RxSwiftExt
import RxService

class ImageSearchCell: UITableViewCell {
    
    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var titleView: UILabel!
    
    var disposeBag: DisposeBag?
    
    var viewModel: ImageSearchViewModel? {
        didSet {
            guard let viewModel = self.viewModel else { return }
            
            let disposeBag = DisposeBag()
            
            viewModel.title
                .map(Optional.init)
                .drive(titleView.rx.text)
                .disposed(by: disposeBag)
            
            viewModel.image
                .drive(thumbnailView.rx.image)
                .disposed(by: disposeBag)
            
            self.disposeBag = disposeBag
        }
    }
}
