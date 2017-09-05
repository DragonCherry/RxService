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
    
    let cellIdentifier = UUID().uuidString
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.hideEmptyCells()
        configureTableSource()
    }
    
    func configureTableSource() {
        let reachabilityService = try! DefaultReachabilityService.shared()
        
        // configure basic UI
        tableView.rowHeight = 130
        tableView.register(UINib(nibName: "ImageSearchCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        
        // handler for selection
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                self?.tableView.deselectRow(at: indexPath, animated: true)
                self?.searchBar.endEditing(true)
        }).disposed(by: disposeBag)
        
        // declare event flow
        let results = searchBar.rx.text.orEmpty
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
            .map { $0.map(ImageSearchViewModel.init) }
        
        // declare cell items to be updated with viewModel
        results.drive(tableView.rx.items(cellIdentifier: cellIdentifier, cellType: ImageSearchCell.self)) { _, viewModel, cell in
            cell.viewModel = viewModel
        }.disposed(by: disposeBag)
        
        // declare empty view to show up when it has no search results
        results.map { $0.count != 0 }
            .drive(emptyView.rx.isHidden)
            .disposed(by: disposeBag)
    }
}
