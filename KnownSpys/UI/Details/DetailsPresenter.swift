//
//  DetailsPresenter.swift
//  KnownSpys
//
//  Created by Sajith Konara on 3/28/20.
//  Copyright © 2020 Sajith Konara. All rights reserved.
//

import Foundation

protocol DetailPresenter {
    var spy: SpyDTO! {get}
    
    var imageName:String {get}
    var name:String {get}
    var age:String {get}
    var gender:String {get}
}

class DetailPresenterIMPL:DetailPresenter {
    
    var spy: SpyDTO!
    
    var imageName:String {return spy.imageName}
    var name:String {return spy.name}
    var age:String {return spy.age.description}
    var gender:String {return spy.gender.rawValue}
    
    init(spy:SpyDTO) {
        self.spy = spy
    }
}
