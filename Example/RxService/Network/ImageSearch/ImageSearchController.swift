//
//  ImageSearchController.swift
//  RxService_Example
//
//  Created by DragonCherry on 7/10/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import RxSwift
import RxCocoa
import RxSwiftExt
import RxService
import TinyLog

class ImageSearchController: UIViewController {
    
    let kImageSearchCellReuseIdentifier: String = "kImageSearchCellReuseIdentifier"
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.hideEmptyCells()
        configureSearchBar()
        configureTableSource()
    }
    
    func configureSearchBar() {
        let reachabilityService = try! DefaultReachabilityService.shared()
        let results = searchBar.rx.text
            .orEmpty
            .asDriver()
            .throttle(0.3)
            .distinctUntilChanged()
            .flatMapLatest { searchText in
                DefaultImageSearchAPI.default.search(query: searchText, start: 1)
                    .retry(3)
                    .retryOnBecomesReachable([], reachabilityService: reachabilityService)
                    .startWith([])
                    .asDriver(onErrorJustReturn: [])
            }
            .map { searchResults in
                searchResults.map(ImageSearchViewModel.init)
            }
        
        results.drive(tableView.rx.items(cellIdentifier: kImageSearchCellReuseIdentifier, cellType: ImageSearchCell.self)) { index, viewModel, cell in
            log("index: \(index)")
            cell.viewModel = viewModel
        }.disposed(by: disposeBag)
        
        results.map { $0.count != 0 }
            .drive(emptyView.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    func configureTableSource() {
        tableView.rowHeight = 130
        tableView.register(UINib(nibName: "ImageSearchCell", bundle: nil), forCellReuseIdentifier: kImageSearchCellReuseIdentifier)
    }
}
