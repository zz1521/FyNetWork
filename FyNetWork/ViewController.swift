//
//  ViewController.swift
//  FyNetWork
//
//  Created by l on 2020/3/16.
//  Copyright © 2020 ifeiyv. All rights reserved.
//

import UIKit
import RxSwift

class ViewController: UIViewController {
    
    var viewModel:FyViewModel?
    
    var tips:UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        viewModel = FyViewModel()
        bindView()
        loadData()
    }
    
    
    //
    func bindView(){
        tips =  UILabel.init(frame: view.frame)
        tips?.numberOfLines = 0
        tips?.font = UIFont.systemFont(ofSize: 30)
        tips?.textColor = UIColor.red
        view.addSubview(tips!)
    }
    func loadData(){
        viewModel?.fetchMusicListData(keyword:"思如雪",networkResultClosure: {[weak self] (names) in
            DispatchQueue.main.async {
                self?.tips?.text = names
            }
        })
    }
    
    


}

