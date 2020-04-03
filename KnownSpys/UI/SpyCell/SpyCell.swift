import UIKit

class SpyCell: UITableViewCell {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var nameValueLabel: UILabel!
    @IBOutlet var ageLabel: UILabel!
    @IBOutlet var ageValueLabel: UILabel!
    @IBOutlet var imageContainer: UIView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        commonInit()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageContainer.subviews.forEach { $0.removeFromSuperview() }
        nameValueLabel.text = ""
        ageValueLabel.text = ""
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK: adding images
extension SpyCell {
    func add(imageName: String) {
        guard let image = UIImage(named: imageName) else { return }
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        imageView.image = image
        
        imageContainer.addSubview(imageView)
    }
}

//MARK: - Configure
extension SpyCell {
    func configure(with presenter: SpyCellPresenterIMPL) {
        
        getSomeData { [weak self] in
            guard let strongSelf = self else { return }
            
            strongSelf.set(age: presenter.age)
            strongSelf.set(name: presenter.name)
            strongSelf.add(imageName: presenter.imageName)
        }
    }
    
    fileprivate func getSomeData(finished: @escaping ()->Void ) {
        
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        
        //faking some network call
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.activityIndicator.stopAnimating()
            self?.activityIndicator.isHidden = true
            
            finished()
        }
    }
}

//MARK: - Dynamic Sizing font - iOS 10
extension SpyCell {
    
    func commonInit() {
        
        setAccessibilityProperties()
        
        if #available(iOS 10, *) {
            commonInit_iOS10()
        } else {
            commonInit_iOS7plus()
        }
    }
    
    func setAccessibilityProperties() {
        nameValueLabel.isAccessibilityElement = true
    }
    
    func set(name: String) {
        nameValueLabel.text = name
        nameValueLabel.accessibilityValue = name
    }
    
    func set(age: Int) {
        ageValueLabel.text  = String(age)
    }
}

@available(iOS 10, *)
extension SpyCell {
    func commonInit_iOS10() {
        nameValueLabel.adjustsFontForContentSizeCategory = true
    }
}

//MARK: - Dynamic Sizing font - iOS 8
@available(iOS 7, *)
extension SpyCell {
    fileprivate func commonInit_iOS7plus() {
        assignFonts()
        
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(userChangedTextSize(notification:)), name: UIContentSizeCategory.didChangeNotification, object: nil)
    }
    
    @objc func userChangedTextSize(notification: NSNotification) {
        assignFonts()
    }
    
    fileprivate func assignFonts() {
        nameValueLabel.font = UIFont.preferredFont(forTextStyle: .body)
    }
}


//MARK: - Helper Methods
extension SpyCell {
    public static var cellId: String {
        return "SpyCell"
    }
    
    public static var bundle: Bundle {
        return Bundle(for: SpyCell.self)
    }
    
    public static var nib: UINib {
        return UINib(nibName: SpyCell.cellId, bundle: SpyCell.bundle)
    }
    
    public static func register(with tableView: UITableView) {
        tableView.register(SpyCell.nib, forCellReuseIdentifier: SpyCell.cellId)
    }
    
    public static func loadFromNib(owner: Any?) -> SpyCell {
        return bundle.loadNibNamed(SpyCell.cellId, owner: owner, options: nil)?.first as! SpyCell
    }
    
    public static func dequeue(from tableView: UITableView, for indexPath: IndexPath, with presenter: SpyCellPresenterIMPL) -> SpyCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: SpyCell.cellId, for: indexPath) as! SpyCell
        cell.configure(with: presenter)
        return cell
    }
}
