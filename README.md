# FyNetWork
结合RxSwift、Moya、和HandyJSON封装网络请求模板


## 文件功能

### FyUrls.swift 

主要放一些请求Url


```

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
        // "正服地址" : "测服地址" (这里是网上搜到的开放接口，没有测试地址，两个都写正式地址)
        return FyUrls.service ? "https://v1.alapi.cn/" : "https://v1.alapi.cn/"
    }
    
    
    //这里写拼接到域名上的Url
    static var searchMusic: String {
        return "api/music/search"
    } 
    
    //.......
     
}

```


<!-- more -->





### FyApi

主要放基于Moya的网络请求配置


```
//
//  FyNetworkApi.swift
//  FyNetWork
//
//  Created by l on 2020/3/16.
//  Copyright © 2020 ifeiyv. All rights reserved.
//

import Moya

enum FyApi {
    case search(keyword:String)
    //....
    case other
}


extension FyApi:TargetType{

    //域名配置
    var baseURL: URL {
        return URL(string: FyUrls.domain)!
    }
    
    //接口路径
    var path: String {
        switch self {
        case .search:
            return FyUrls.searchMusic
        default:
            return ""
        }
    }
    
    //请求的方式 可以根据接口切换请求方式 get、post或者其他
    var method: Moya.Method {
        switch self {
        
        case .search:
            return .get
        default:
            return .post
        }
    }
    
    //做单元测试使用的数据
    var sampleData: Data {
        return "{}".data(using: String.Encoding.utf8)!
    }
    
    
    //所有要执行的接口任务，参数的配置在这里设置
    var task: Task {
        switch self {
        case .search(let keyword):
            let params = FyParams.init(params: ["keyword" : keyword])
            return .requestParameters(parameters: params.allParams, encoding: URLEncoding.default)
        default:
            return .requestPlain
        }
    }
    
    //默认请求头配置 
    //也可以在FyRequest.swift的 requestTimeoutClosure中进行动态配置
    var headers: [String : String]? {
        switch self {
        default:
            return ["Content-type": "application/json"]
        }
    }
    
    
    
}
```


### FyRequest.swift

主要放Api接口请求方法具体实现

```
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
    
    
    //接口具体请求实现
    public func searchSongs(keyword:String) ->  Single<Result<Songs>>{
        return  provider.rx.request(.search(keyword: keyword))
            .filterSuccessfulStatusCodes() //删选请求成功状态数据
            .mapModel()                    //数据模型化
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


```

### FyResponse.swift

主要是请求响应解析方法

```
//
//  FyResponse.swift
//  FyNetWork
//
//  Created by l on 2020/3/16.
//  Copyright © 2020 ifeiyv. All rights reserved.
//
import UIKit
import Moya
import RxSwift
import HandyJSON

extension Array: HandyJSON {}
extension String: HandyJSON {}


//采用泛型解析数据
struct FyResponse<T:HandyJSON>:HandyJSON{
    var code:Int = 0
    var message:String?
    var data: T?
    
    var isSuccess: Bool {
         return code == 200
     }
}


extension Response {
    
    //响应数据转model
    func mapModel<T>() throws -> FyResponse<T> {
        do {
            if let jsonString = String(data: data, encoding: String.Encoding.utf8){
                if let obj = JSONDeserializer<FyResponse<T>>.deserializeFrom(json: jsonString) {
                    return obj
                }
                throw RxMoyaError.modelMapping(self)
            } else {
                throw RxMoyaError.modelMapping(self)
            }
        } catch {
            throw RxMoyaError.modelMapping(self)
        }
    }

}


extension PrimitiveSequence where TraitType == SingleTrait, ElementType == Response {
    func mapModel<T: HandyJSON>() -> Single<FyResponse<T>> {
        return flatMap { (response) -> Single<FyResponse<T>> in
            return Single.just(try response.mapModel())
        }
    }
}

```



### FyNetError.swift

请求错误处理


### FySongResponse.swift

请求歌曲列表model例子

### FyViewModel.swift

网络请求库的运用例子

```
//
//  FyViewModel.swift
//  FyNetWork
//
//  Created by l on 2020/3/16.
//  Copyright © 2020 ifeiyv. All rights reserved.
//
import UIKit
import RxSwift

class FyViewModel: NSObject {
    var dispose = DisposeBag()
    
    public typealias NetworkResultClosure = (_ names:String) -> Void
    

    func fetchMusicListData(keyword:String,networkResultClosure: @escaping NetworkResultClosure){
        _ =  FyRequest.request.searchSongs(keyword: keyword).subscribe(onSuccess: { (result) in
            switch result{
            case.regular(let songsInfo):
                var name:String = ""
                for song in songsInfo.songs{
                    name = name + "\n" + song.name
                }
               networkResultClosure(name)
            case .failing( _):
                break
            }
        }) { (error) in
            
        }.disposed(by: dispose)
    }
    
}

//============ViewController.swift=================

 func loadData(){ //接口调用方式
        viewModel?.fetchMusicListData(keyword:"思如雪",networkResultClosure: {[weak self] (names) in
            DispatchQueue.main.async {
                self?.tips?.text = names
            }
        })
 }

```






### FyParams.swift

主要用来配置请求参数

```
//
//  FyParams.swift
//  Runner
//
//  Created by l on 2020/3/16.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//
import UIKit

class FyBaseParams: NSObject {

    var channel : String  {
        return "com.lpf.FyNetWork"
    }
    
    var vno : Int  {
        return 100
    }
    
    /// .........................
    
    
    //这里面存放一些通用参数（也就是每个接口都要携带的参数）
    var baseParams:[String:Any]?{
        var tempParams:[String:Any] = [String:Any]()
        tempParams["channel"] = channel
        tempParams["vno"] = vno
        return tempParams
    }
    
    //这里存放所有请求需要的参数
    var allParams:[String:Any]!
}


//根据接口需要的参数需求不同，进行适当的修改
class FyParams: FyBaseParams {
    
    init(params:[String:Any]? = [String:Any]()) {
        super.init()
        var tempParams = [String:Any]()
        for param in baseParams ?? [String:Any](){
            tempParams[param.key] = param.value
        }
        for param in params ?? [String:Any](){
            tempParams[param.key] = param.value
        }
        allParams = tempParams ?? [String:Any]()
    }
    

}
```
