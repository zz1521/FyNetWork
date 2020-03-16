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

struct FyResponse<T:HandyJSON>:HandyJSON{
    var code:Int = 0
    var message:String?
    var data: T?
    
    var isSuccess: Bool {
         return code == 200
     }
}


extension Response {
    
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

