//
//  FyNetError.swift
//  FyNetWork
//
//  Created by l on 2020/3/16.
//  Copyright © 2020 ifeiyv. All rights reserved.
//


import Foundation
import Moya

class ErrorUtil {
    
    private static let HTTP_ERROR = [
        [400, -2], //（错误请求） 服务器不理解请求的语法。
        [401, -3], //（未授权） 请求要求身份验证。 对于需要登录的网页，服务器可能返回此响应。
        [402, -4], //
        [403, -5], //（禁止） 服务器拒绝请求。
        [404, -6], //（未找到） 服务器找不到请求的网页
        [405, -7], //（方法禁用） 禁用请求中指定的方法。
        [406, -8], //（不接受） 无法使用请求的内容特性响应请求的网页。
        [407, -9], //（需要代理授权） 此状态代码与 401（未授权）类似，但指定请求者应当授权使用代理。
        [408, -10], //（请求超时） 服务器等候请求时发生超时。
        [409, -11], //（冲突） 服务器在完成请求时发生冲突。 服务器必须在响应中包含有关冲突的信息。
        [410, -12], //（已删除） 如果请求的资源已永久删除，服务器就会返回此响应。
        [411, -13], //（需要有效长度） 服务器不接受不含有效内容长度标头字段的请求。
        [412, -14], //（未满足前提条件） 服务器未满足请求者在请求中设置的其中一个前提条件。
        [413, -15], //（请求实体过大） 服务器无法处理请求，因为请求实体过大，超出服务器的处理能力。
        [414, -16], //（请求的 URI 过长） 请求的 URI（通常为网址）过长，服务器无法处理。
        [415, -17], //（不支持的媒体类型） 请求的格式不受请求页面的支持。
        [416, -18], //（请求范围不符合要求） 如果页面无法提供请求的范围，则服务器会返回此状态代码。
        [417, -19], //（未满足期望值） 服务器未满足"期望"请求标头字段的要求。
        
        [500, -50], //（服务器内部错误） 服务器遇到错误，无法完成请求。
        [501, -51], //（尚未实施） 服务器不具备完成请求的功能。 例如，服务器无法识别请求方法时可能会返回此代码。
        [502, -52], //（错误网关） 服务器作为网关或代理，从上游服务器收到无效响应。
        [503, -53], //（服务不可用） 服务器目前无法使用（由于超载或停机维护）。 通常，这只是暂时状态。
        [504, -54], //（网关超时） 服务器作为网关或代理，但是没有及时从上游服务器收到请求。
        [505, -55]  //（HTTP 版本不受支持） 服务器不支持请求中所用的 HTTP 协议版本。
    ]
    
    static func fetchCode(_ statusCode: Int) -> Int {
        var err = statusCode;
        
        HTTP_ERROR.forEach { codePatten in
            if statusCode == codePatten[0] {
                err = codePatten[1]
                return
            }
        }
        
        return err;
    }
    
}

enum Result<T> {
    case regular(T)
    case failing(Swift.Error)
    
    
    // 错误信息转义
    static func returnMessage(_ inError: Result<Any>?) -> String? {
        if let errorObjc = inError {
            switch errorObjc {
            case .regular(let value):
                return value as? String
            case .failing(let error):
                if let err = error as? MoyaError {
                    if let response = err.response {
                        let errorCode = ErrorUtil.fetchCode(response.statusCode)
                        return errorCode == -1 ? (err.errorDescription ?? "") : "网络连接异常 \(errorCode)"
                    } else {
                        switch err {
                        case .underlying(_, nil):
                            return "网络连接异常 -1"
                        case .statusCode(let response):
                            return "网络连接异常 \(response.statusCode)"
                        default:
                            return "网络连接异常"
                        }
                    }
                } else if let err = error as? RxMoyaError {
                    if let response = err.response {
                        let errorCode = ErrorUtil.fetchCode(response.statusCode)
                        return errorCode == -1 ? (err.errorDescription ?? "") : "网络连接异常 \(errorCode)"
                    } else {
                        return err.errorDescription ?? ""
                    }
                }
                return error.localizedDescription
            }
        } else {
            return nil
        }
    }
}

enum RxMoyaError: Swift.Error {
    case modelMapping(Response)
    case reason(String)
}

extension RxMoyaError {
    var response: Moya.Response? {
        switch self {
        case .modelMapping(let response):
            return response
        default:
            return nil
        }
    }
}

extension RxMoyaError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .modelMapping:
            return "modelMapping转换失败"
        case .reason(let reason):
            return reason
        }
    }
}



enum ErrorTips: String {
    case netWorkError            = "网络异常，请检查网络"
    case dataError               = "数据解析失败，状态-1"
    case serverError           = "服务器访问异常，请稍后重试"
}

enum SuccessTips: String {
    case success      = "请求数据成功"
}
