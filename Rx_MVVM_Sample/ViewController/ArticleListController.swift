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

class ArticleListController: UIViewController {
        
    @IBOutlet weak var nameSearchBar: UISearchBar!
    @IBOutlet var articleListTableView: UITableView!
  
    let disposeBag = DisposeBag()
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
        setupRx()
        setupUI()     
    }
 
    func setupRx(){       
        articleViewModel = ArticleViewModel(withNameObservable: rx_searchBarText)
        
        articleViewModel
        .rx_articles
            .drive(articleListTableView.rx.items) { (tableView, i, article) in
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: IndexPath(row: i,section:0))
                cell.textLabel?.text = article.title
                cell.detailTextLabel?.text = article.url
                
                return cell
        }
        .disposed(by: disposeBag)
       
        articleViewModel
        .rx_articles
            .drive(onNext: { articles in
                if articles.count == 0 {
                    let alert = UIAlertController(title: "(|-|)", message: "No Articles", preferredStyle: .alert)
                 alert.addAction(UIAlertAction(title: "OK!", style: .default, handler: nil))
                
                    if self.navigationController?.visibleViewController is UIAlertController != true {
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                    
                }
            })
        .disposed(by: disposeBag) 
    }
   
    func setupUI(){     
        let tap = UITapGestureRecognizer(target: self, action: #selector(tableTapped(_:)))
        articleListTableView.addGestureRecognizer(tap)
    }
    
    @objc func tableTapped(_ recognizer: UITapGestureRecognizer) {    
        let location = recognizer.location(in: articleListTableView)
        let path = articleListTableView.indexPathForRow(at: location)
        
        if nameSearchBar.isFirstResponder {
            nameSearchBar.resignFirstResponder()
        } else if let path = path {
            articleListTableView.selectRow(at: path, animated: true, scrollPosition: .middle)
        }
    }
}
