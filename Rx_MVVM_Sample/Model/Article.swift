//
//  Article.swift
//  Rx_MVVM_Sample
//
//  Created by SHORYU on 2019/05/25.
//  Copyright © 2019年 SHORYU. All rights reserved.
//


//Qiitaの記事の抽出項目を決める
import ObjectMapper

class Article: Mappable {
    var title:String!
    var url: String!
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        title <- map["title"]
        url <- map["url"]
    }
}

