import UIKit
import Swinject
import SwinjectStoryboard

protocol DependencyRegistry {
    var container: Container {get}
    var navigationCoordinator:NavigationCoordinator! {get}
    
    typealias rootNavigationCoordinatorMaker = (UIViewController) -> NavigationCoordinator
    func makeRootNavigationCoordinator(rootViewController:UIViewController) -> NavigationCoordinator
    
    typealias SpyCellMaker = (UITableView, IndexPath, SpyDTO) -> SpyCell
    func makeSpyCell(for tableView: UITableView, at indexPath: IndexPath, spy: SpyDTO) -> SpyCell
    
    typealias DetailViewControllerMaker = (SpyDTO) -> DetailViewController
    func makeDetailViewController(with spy: SpyDTO) -> DetailViewController
    
    typealias SecretDetailsViewControllerMaker = (SpyDTO)  -> SecretDetailsViewController
    func makeSecretDetailsViewController(with spy: SpyDTO) -> SecretDetailsViewController
}

class DependencyRegistryIMPL:DependencyRegistry {
    
    var navigationCoordinator: NavigationCoordinator!
    var container: Container
    
    init(container: Container) {
        
        Container.loggingFunction = nil
        
        self.container = container
        
        registerDependencies()
        registerPresenters()
        registerViewControllers()
    }
    
    func registerDependencies() {
        
        container.register(NetworkLayerIMPL.self) { _ in NetworkLayerIMPL()  }.inObjectScope(.container)
        container.register(DataLayerIMPL.self) { _ in DataLayerIMPL()     }.inObjectScope(.container)
        container.register(SpyTranslatorIMPL.self) { _ in SpyTranslatorIMPL() }.inObjectScope(.container)
        
        container.register(TranslationLayerIMPL.self) { r in
            TranslationLayerIMPL(spyTranslator: r.resolve(SpyTranslatorIMPL.self)!)
        }.inObjectScope(.container)
        
        container.register(ModelLayerIMPL.self){ r in
            ModelLayerIMPL(networkLayer: r.resolve(NetworkLayerIMPL.self)!,
                           dataLayer: r.resolve(DataLayerIMPL.self)!,
                           translationLayer: r.resolve(TranslationLayerIMPL.self)!)
        }.inObjectScope(.container)
        
        container.register(NavigationCoordinator.self){(r, rootViewController:UIViewController) in
            return RootNavigationCoordinatorImpl(with: rootViewController, registry: self)
        }.inObjectScope(.container)
    }
    
    func registerPresenters() {
        container.register(SpyListPresenterIMPL.self) { r in SpyListPresenterIMPL(modelLayer: r.resolve(ModelLayerIMPL.self)!) }
        container.register( DetailPresenterIMPL.self) { (r, spy: SpyDTO)  in DetailPresenterIMPL(spy: spy) }
        container.register(SpyCellPresenterIMPL.self) { (r, spy: SpyDTO) in SpyCellPresenterIMPL(spy: spy) }
        container.register(SecretDetailPresenterIMPL.self) { (r, spy: SpyDTO) in SecretDetailPresenterIMPL(spyDTO: spy) }
    }
    
    func registerViewControllers() {
        container.register(SecretDetailsViewController.self) { (r, spy: SpyDTO) in
            let presenter = r.resolve(SecretDetailPresenterIMPL.self, argument: spy)!
            return SecretDetailsViewController(with: presenter, navigationCoordinator: self.navigationCoordinator)
        }
        container.register(DetailViewController.self) { (r, spy:SpyDTO) in
            let presenter = r.resolve(DetailPresenterIMPL.self, argument: spy)!
            
            //NOTE: We don't have access to the constructor for this VC so we are using method injection
            let vc = UIStoryboard.main.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            vc.configure(with: presenter, navigationCoordinator: self.navigationCoordinator)
            return vc
        }
    }
    
    //MARK: - Maker Methods
    func makeSpyCell(for tableView: UITableView, at indexPath: IndexPath, spy: SpyDTO) -> SpyCell {
        let presenter = container.resolve(SpyCellPresenterIMPL.self, argument: spy)!
        let cell = SpyCell.dequeue(from: tableView, for: indexPath, with: presenter)
        return cell
    }
    
    func makeDetailViewController(with spy: SpyDTO) -> DetailViewController {
        return container.resolve(DetailViewController.self, argument: spy)!
    }
    
    
    func makeSecretDetailsViewController(with spy: SpyDTO) -> SecretDetailsViewController {
        return container.resolve(SecretDetailsViewController.self, argument: spy)!
    }
    
    func makeRootNavigationCoordinator(rootViewController:UIViewController) -> NavigationCoordinator{
        navigationCoordinator = container.resolve(NavigationCoordinator.self,argument: rootViewController)!
        return navigationCoordinator
    }
}
