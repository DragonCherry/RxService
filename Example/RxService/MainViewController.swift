//
//  ViewController.swift
//  RxService
//
//  Created by DragonCherry on 07/05/2017.
//  Copyright (c) 2017 DragonCherry. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.hideEmptyCells()
    }
}

extension UITableView {
    func hideEmptyCells() { tableFooterView = UIView() }
}
