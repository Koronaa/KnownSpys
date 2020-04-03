//
//  DatabaseLayer.swift
//  KnownSpys
//
//  Created by Sajith Konara on 3/28/20.
//  Copyright © 2020 Sajith Konara. All rights reserved.
//

import Foundation
import CoreData
import UIKit

typealias SpiesBlock = ([Spy])->Void

protocol DataLayer {
    func save(dtos: [SpyDTO], tranlationLayer:TranslationLayerIMPL, finished: @escaping () -> Void)
    func loadSpiesFromDB() -> [Spy]
}

class DataLayerIMPL:DataLayer{
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "KnownSpys")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func save(dtos: [SpyDTO], tranlationLayer:TranslationLayerIMPL, finished: @escaping () -> Void) {
        clearOldResults()
        _ = tranlationLayer.toUnsavedCoreData(from: dtos, with: mainContext)
        try! mainContext.save()
        finished()
    }
    
    func loadFromDB(finished: SpiesBlock) {
        print("loading data locally")
        let spies = loadSpiesFromDB()
        finished(spies)
    }
    
    
    internal func loadSpiesFromDB() -> [Spy] {
        let sortOn = NSSortDescriptor(key: "name", ascending: true)
        
        let fetchRequest: NSFetchRequest<Spy> = Spy.fetchRequest()
        fetchRequest.sortDescriptors = [sortOn]
        
        let spies = try! persistentContainer.viewContext.fetch(fetchRequest)
        
        return spies
    }
    
    fileprivate func clearOldResults() {
        print("clearing old results")
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Spy.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        try! persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: persistentContainer.viewContext)
        persistentContainer.viewContext.reset()
    }
}
