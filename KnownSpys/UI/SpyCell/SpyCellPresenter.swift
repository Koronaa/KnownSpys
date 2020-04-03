//
//  SpyCellPresenter.swift
//  KnownSpys
//
//  Created by Sajith Konara on 3/28/20.
//  Copyright © 2020 Sajith Konara. All rights reserved.
//

import Foundation

protocol SpyCellPresenter {
    var age:Int {get}
    var name:String {get}
    var imageName:String {get}
}

class SpyCellPresenterIMPL:SpyCellPresenter{
    var spy: SpyDTO
    
    var age:Int {return Int(spy.age)}
    var name:String {return spy.name}
    var imageName:String {return spy.imageName}
    
    init(spy:SpyDTO) {
        self.spy = spy
    }
}
