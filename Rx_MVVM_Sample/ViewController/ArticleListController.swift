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
    
    
//    UI parts
    @IBOutlet weak var nameSearchBar: UISearchBar!
    
    @IBOutlet var articleListTableView: UITableView!
    
    
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
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
        setupRx()
        setupUI()
        
        
    }
    
    //ViewModelを経由してQiitaの情報を取得してテーブルビューに検索結果を表示する
    func setupRx(){
        
        articleViewModel = ArticleViewModel(withNameObservable: rx_searchBarText)
        
        //リクエストした結果の更新を元に表示に関する処理を行う（テーブルビューへのデータ一覧の表示処理）
        articleViewModel
        .rx_articles
            .drive(articleListTableView.rx.items) { (tableView, i, article) in
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: IndexPath(row: i,section:0))
                cell.textLabel?.text = article.title
                cell.detailTextLabel?.text = article.url
                
                return cell
        }
        .disposed(by: disposeBag)
       
        //リクエストした結果の更新を元に表示に関する処理を行う（取得したデータの件数に応じたエラーハンドリング処理）
        articleViewModel
        .rx_articles
            .drive(onNext: { articles in
                if articles.count == 0 {
                    let alert = UIAlertController(title: ":(", message: "No Articles", preferredStyle: .alert)
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
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        
        //Case2. キーボードを閉じた場合のイベント
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }




    @objc func keyboardWillShow(_ notification: Notification) {
        
        //キーボードのサイズを取得する（英語のキーボードが基準になるので日本語のキーボードだと少し見切れてしまう）
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        //一覧表示用テーブルビューのAutoLayoutの制約を更新して高さをキーボード分だけ縮める
        tableViewBottomConstraint.constant = keyboardFrame.height
        UIView.animate(withDuration: 0.3, animations: {
            self.view.updateConstraints()
        })
    }

    //キーボード非表示表示時に発動されるメソッド
    @objc func keyboardWillHide(_ notification: Notification) {
        
        //一覧表示用テーブルビューのAutoLayoutの制約を更新して高さを元に戻す
        tableViewBottomConstraint.constant = 0.0
        UIView.animate(withDuration: 0.3, animations: {
            self.view.updateConstraints()
        })
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }


    
    //テーブルビューのセルタップ時に発動されるメソッド
    @objc func tableTapped(_ recognizer: UITapGestureRecognizer) {
        
        //どのセルがタップされたかを探知する
        let location = recognizer.location(in: articleListTableView)
        let path = articleListTableView.indexPathForRow(at: location)
        
        //キーボードが表示されているか否かで処理を分ける
        if nameSearchBar.isFirstResponder {
            
            //キーボードを閉じる
            nameSearchBar.resignFirstResponder()
            
        } else if let path = path {
            
            //タップされたセルを中央位置に持ってくる
            articleListTableView.selectRow(at: path, animated: true, scrollPosition: .middle)
        }
        
    }

}
