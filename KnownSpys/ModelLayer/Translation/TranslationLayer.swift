//
//  TranslationLayer.swift
//  KnownSpys
//
//  Created by Sajith Konara on 3/28/20.
//  Copyright © 2020 Sajith Konara. All rights reserved.
//

import Foundation
import Outlaw
import CoreData

protocol TranslationLayer {
    func createSpyDTOsFromJsonData(_ data: Data) -> [SpyDTO]
    func toUnsavedCoreData(from dtos: [SpyDTO], with context: NSManagedObjectContext) -> [Spy]
    func toSpyDTOs(from spies:[Spy]) -> [SpyDTO]
}

class TranslationLayerIMPL:TranslationLayer{
    
    fileprivate var spyTranslator:SpyTranslatorIMPL
    
    init(spyTranslator:SpyTranslatorIMPL) {
        self.spyTranslator = spyTranslator
    }
    
    func createSpyDTOsFromJsonData(_ data: Data) -> [SpyDTO] {
        print("converting json to DTOs")
        let json:[String: Any] = try! JSON.value(from: data)
        let spies: [SpyDTO] = try! json.value(for: "spies")
        return spies
    }
    
    func toUnsavedCoreData(from dtos: [SpyDTO], with context: NSManagedObjectContext) -> [Spy] {
        print("convering DTOs to Core Data Objects")
        let spies = dtos.compactMap{ dto in spyTranslator.translate(from: dto, with: context) } // keeping it simple by keeping things single threaded
        
        return spies
    }
    
    func toSpyDTOs(from spies:[Spy]) -> [SpyDTO] {
        let dtos = spies.compactMap { spyTranslator.translate(from: $0) }
        
        return dtos
    }
}
