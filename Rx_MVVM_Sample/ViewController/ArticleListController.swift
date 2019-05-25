//
//  ViewController.swift
//  Rx_MVVM_Sample
//
//  Created by SHORYU on 2019/05/25.
//  Copyright © 2019年 SHORYU. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ObjectMapper
import RxAlamofire


class ArticleListController: UITableViewController {
    
    
//    UI parts
    @IBOutlet weak var nameSearchBar: UISearchBar!
    @IBOutlet var articleListTableView: UITableView!
    
    
    let disposeBag = DisposeBag()
    
//    ViewModelのインスタンス格納用
    var articleViewModel: ArticleViewModel!
    
    var rx_searchBarText: Observable<String> {
        return nameSearchBar.rx.text
            .filter { $0 != nil }
            .map { $0! }
            .filter{ $0.count > 0 }
        .debounce(0.5, scheduler: MainScheduler.instance)
        .distinctUntilChanged()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }


}

