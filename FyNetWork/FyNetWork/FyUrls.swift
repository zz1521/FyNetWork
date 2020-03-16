//
//  FyUrls.swift
//  FyNetWork
//
//  Created by l on 2020/3/16.
//  Copyright © 2020 ifeiyv. All rights reserved.
//





struct FyUrls {
    /// 服务器环境 true: 正服 false: 测服
    #if DEBUG
    //测试环境
    static let service: Bool = false
    #else
    //正式环境
    static let service: Bool = true
    #endif

    static var domain: String {
        // "正服地址" : "测服地址"
        return FyUrls.service ? "https://v1.alapi.cn/" : "https://v1.alapi.cn/"
    }
    
    //搜索歌曲
   static var searchMusic: String {
        return "api/music/search"
    } 
    
    
    
    
    
}
