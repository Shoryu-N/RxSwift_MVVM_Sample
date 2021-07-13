//
//  ArticleViewModel.swift
//  Rx_MVVM_Sample
//
//  Created by SHORYU on 2019/05/25.
//  Copyright © 2019年 SHORYU. All rights reserved.
//

import ObjectMapper
import RxAlamofire
import RxCocoa
import RxSwift

struct ArticleViewModel {    
    lazy var rx_articles: Driver<[Article]> = self.fetchArticles()
    private var articleName: Observable<String>
    init(withNameObservable nameObservable: Observable<String>) {
        self.articleName = nameObservable
    }
    
    private func fetchArticles() -> Driver<[Article]> {
        return articleName
        .subscribeOn(MainScheduler.instance)
            .do(onNext: { response in
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            })
        .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
        .flatMapLatest { text in
                return RxAlamofire
                    .requestJSON(.get, "https://qiita.com/api/v2/items?page=1&query=tag%3A\(text)")
                    .debug()
                    .catchError { error in
                        
                        return Observable.never()
                }
        }
        .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
        .map { (response, json) -> [Article] in
            if let art = Mapper<Article>().mapArray(JSONObject: json) {
                return art
            } else {
                return []
            }
                
        }
        .observeOn(MainScheduler.instance)
        .do(onNext: { response in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            })
        .asDriver(onErrorJustReturn: [])
    }
}
