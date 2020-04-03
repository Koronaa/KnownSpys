//
//  SecretDetailPresenter.swift
//  KnownSpys
//
//  Created by Sajith Konara on 3/28/20.
//  Copyright © 2020 Sajith Konara. All rights reserved.
//

import Foundation

protocol SecretDetailPresenter {
    var password:String {get}
}

class SecretDetailPresenterIMPL:SecretDetailPresenter{
    
    var spyDTO: SpyDTO
    var password:String {return spyDTO.password}
    
    init(spyDTO:SpyDTO) {
        self.spyDTO = spyDTO
    }
    
}
