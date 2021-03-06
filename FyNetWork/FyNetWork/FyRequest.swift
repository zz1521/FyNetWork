//
//  FyRequest.swift
//  FyNetWork
//
//  Created by l on 2020/3/16.
//  Copyright © 2020 ifeiyv. All rights reserved.
//

import UIKit
import Moya
import RxSwift


let requestTimeoutClosure = { (endpoint: Endpoint, done: @escaping MoyaProvider<FyApi>.RequestResultClosure) in
    do {
        var request = try endpoint.urlRequest()

        //根据不同接口判断携带不同的请求头 //这个也可以根据接口判断，切换超时时长
        if(request.url?.absoluteString.contains(FyUrls.searchMusic.lowercased()) ?? false){
            request.timeoutInterval = 30
            request.addValue("zhangsan", forHTTPHeaderField: "user")
            request.addValue("ahsfksjfhskdfhsjdkf", forHTTPHeaderField: "cookie")
        }else{
            //.....
            request.timeoutInterval = 10
        }
        done(.success(request))
    } catch {
        return
    }
}


class FyRequest: NSObject {
    static let request = FyRequest()
    
    var provider = MoyaProvider<FyApi> (requestClosure: requestTimeoutClosure,plugins: [NetworkLoggerPlugin(verbose: true)])
    
    
    //    var provider = MoyaProvider<FyApi> (
    //        plugins: [NetworkLoggerPlugin(verbose: false)]
    //    )
    
    public func searchSongs(keyword:String) ->  Single<Result<Songs>>{
        return  provider.rx.request(.search(keyword: keyword))
            .filterSuccessfulStatusCodes()
            .mapModel()
            .flatMap { (result: FyResponse<Songs>) in
                if result.isSuccess{
                    return  Single.just(Result.regular(result.data ?? Songs()))
                }else{
                    return Single.just(Result<Songs>.failing(RxMoyaError.reason(result.message ?? "")))
                    
                }
        }
        .catchError({ error in
            return Single.just(Result.failing(RxMoyaError.reason(ErrorTips.netWorkError.rawValue)))
        })
        
    }
}



