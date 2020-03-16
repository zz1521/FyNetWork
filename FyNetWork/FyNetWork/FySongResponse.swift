//
//  FymusicBroadcasting.swift
//  FyNetWork
//
//  Created by l on 2020/3/16.
//  Copyright © 2020 ifeiyv. All rights reserved.
//

import HandyJSON

struct Songs :HandyJSON{
    var songs:[Song] = [Song]()
}

struct Song:HandyJSON{
    var id:Int = 0
    var name:String = ""
}
