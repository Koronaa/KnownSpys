//
//  ModelLayer.swift
//  KnownSpys
//
//  Created by Sajith Konara on 3/28/20.
//  Copyright © 2020 Sajith Konara. All rights reserved.
//

import Foundation

typealias SpiesAndSourceBlock = (Source, [SpyDTO])->Void

protocol ModelLayer {
    func loadData(resultsLoaded: @escaping SpiesAndSourceBlock)
}

class ModelLayerIMPL:ModelLayer{
    
    fileprivate var networkLayer:NetworkLayerIMPL
    fileprivate var dataLayer:DataLayerIMPL
    fileprivate var translationLayer:TranslationLayerIMPL
    
    init(networkLayer:NetworkLayerIMPL,dataLayer:DataLayerIMPL,translationLayer:TranslationLayerIMPL) {
        self.networkLayer = networkLayer
        self.dataLayer = dataLayer
        self.translationLayer = translationLayer
    }
    
    func loadData(resultsLoaded: @escaping SpiesAndSourceBlock) {
        func mainWork() {
            
            loadFromDB(from: .local)
            
            networkLayer.loadFromServer { data in
                let dtos = self.translationLayer.createSpyDTOsFromJsonData(data)
                self.dataLayer.save(dtos: dtos , tranlationLayer: self.translationLayer) {
                    loadFromDB(from: .network)
                }
            }
        }
        
        func loadFromDB(from source: Source) {
            dataLayer.loadFromDB { spies in
                let dtos = translationLayer.toSpyDTOs(from: spies)
                resultsLoaded(source, dtos)
            }
        }
        
        mainWork()
    }
}





