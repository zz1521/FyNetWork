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
    let tipsStrOB = BehaviorSubject(value: "")
    
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
