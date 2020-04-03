//
//  NavigationCoordinator.swift
//  KnownSpys
//
//  Created by Jon Bott on 4/20/17.
//  Copyright © 2017 JonBott.com. All rights reserved.
//

import UIKit

protocol NavigationCoordinator: class {
    func next(arguments: Dictionary<String, Any>?)
    func movingBack()
}

enum NavigationState {
    case atSpyList,
         atSpyDetails,
         atSecretDetails,
         inSignupProcess
}

class RootNavigationCoordinatorImpl: NavigationCoordinator {
    
    var registry: DependencyRegistry
    var rootViewController: UIViewController

    var navState: NavigationState = .atSpyList
    
    init(with rootViewController: UIViewController, registry: DependencyRegistry) {
        self.rootViewController = rootViewController
        self.registry = registry
    }
    
    func movingBack() {
        switch navState {
        case .atSpyList: //not possible to move back - do nothing
            break
        case .atSpyDetails:
            navState = .atSpyList
        case .atSecretDetails:
            navState = .atSpyDetails
        case .inSignupProcess: //example - do nothing
            break
        }
    }
    
    func next(arguments: Dictionary<String, Any>?) {
        switch navState {
        case .atSpyList:
            showDetails(arguments: arguments)
        case .atSpyDetails:
            showSecretDetails(arguments: arguments)
        case .atSecretDetails:
            showSpyList()
        case .inSignupProcess: //example - do nothing
            break
        }
    }
    
    func showDetails(arguments: Dictionary<String, Any>?) {
        guard let spy = arguments?["spy"] as? SpyDTO else { notifyNilArguments(); return }
        
        let detailViewController = registry.makeDetailViewController(with: spy)
        
        rootViewController.navigationController?.pushViewController(detailViewController, animated: true)
        navState = .atSpyDetails
    }
    
    func showSecretDetails(arguments: Dictionary<String, Any>?) {
        guard let spy = arguments?["spy"] as? SpyDTO else { notifyNilArguments(); return }

        let detailViewController = registry.makeSecretDetailsViewController(with: spy)
        
        rootViewController.navigationController?.pushViewController(detailViewController, animated: true)
        navState = .atSecretDetails
    }
    
    func showSpyList() {
        rootViewController.navigationController?.popToRootViewController(animated: true)
        navState = .atSpyList
    }
    
    func notifyNilArguments() {
        print("notify user of error")
    }
}
