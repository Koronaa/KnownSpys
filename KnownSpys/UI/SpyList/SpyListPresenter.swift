//
//  SpyListPresenter.swift
//  KnownSpys
//
//  Created by Sajith Konara on 3/28/20.
//  Copyright © 2020 Sajith Konara. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources
import RxCocoa


typealias BlockWithSource = (Source)->Void

struct SpySection {
    var header:String
    var items:[Item]
}

extension SpySection:SectionModelType{
    typealias Item = SpyDTO
    
    init(original: SpySection, items: [Item]) {
        self = original
        self.items = items
    }
}

protocol SpyListPresenter {
    var sections: BehaviorRelay<[SpySection]> {get}
    func loadData(finished: @escaping BlockWithSource)
    func makeSomeDataChange()
}

class SpyListPresenterIMPL:SpyListPresenter{
    
    var sections = BehaviorRelay<[SpySection]>(value: [])
    fileprivate var modelLayer:ModelLayerIMPL
    fileprivate var bag:DisposeBag = DisposeBag()
    fileprivate var spies = BehaviorRelay<[SpyDTO]>(value: [])
    
    init(modelLayer:ModelLayerIMPL) {
        self.modelLayer = modelLayer
        setupObserver()
    }
    
    func loadData(finished: @escaping BlockWithSource) {
        modelLayer.loadData { [weak self] source, spies in
            self?.spies.accept(spies)
            finished(source)
        }
    }
    
    func makeSomeDataChange() {
        let newSpy = SpyDTO(age: 29, name: "Sajith Konara", gender: .male, password: "123", imageName: "AdamSmith", isIncognito: true)
        var newSpies:[SpyDTO] = []
        newSpies.append(newSpy)
        spies.accept(newSpies + spies.value)
    }
    
    //MARK: Reactive Observers
    func setupObserver(){
        spies.asObservable().subscribe(onNext: { [weak self] newSpies in
            self?.updateNewSections(with: newSpies)
        }).disposed(by: bag)
    }
    
    func updateNewSections(with newSpies:[SpyDTO]){
        func mainWork(){
            sections.accept(filer(spies:newSpies))
        }
        
        func filer(spies:[SpyDTO]) -> [SpySection]{
            let incognitoSpies = spies.filter {$0.isIncognito}
            let everydaySpies = spies.filter {!$0.isIncognito}
            
            return [SpySection(header: "Incognito Spies", items: incognitoSpies),
                    SpySection(header: "Everyday Spies", items: everydaySpies)]
            
        }
        mainWork()
    }
}












