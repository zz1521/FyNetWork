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

    var baseURL: URL {
        return URL(string: FyUrls.domain)!
    }
    
    var path: String {
        switch self {
        default:
            return "api/music/search"
        }
    }
    
    var method: Moya.Method {
        switch self {
        default:
            return .get
        }
    }
    
    var sampleData: Data {
        return "{}".data(using: String.Encoding.utf8)!
    }
    
    var task: Task {
        switch self {
        case .search(let keyword):
            var params:[String:Any] = [String:Any]()
            params["keyword"] = keyword
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        default:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        default:
            return ["Content-type": "application/json"]
        }
    }
    
    
    
}
