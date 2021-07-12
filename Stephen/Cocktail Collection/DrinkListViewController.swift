//
//  DrinkListViewController.swift
//  Stephen
//
//  Created by João Leite on 29/06/21.
//

import UIKit
import RxSwift
import RxCocoa

enum CollectionSections {
    case Title(String), Favorite, RequestList, List
}

class UnderlineTextField : UITextField, UITextFieldDelegate {
    
    @IBInspectable public var underlineActiveColor : UIColor = .gray
    @IBInspectable public var underlineInactiveColor : UIColor = .gray
    
    private var underlineView : UIView!
    
    override func draw(_ rect: CGRect) {
        
        delegate = self
        
        guard underlineView == nil else { return }
        
        underlineView = UIView()
        underlineView.translatesAutoresizingMaskIntoConstraints = false
        underlineView.backgroundColor = underlineInactiveColor
        
        addSubview(underlineView)
        NSLayoutConstraint.activate([
            underlineView.leadingAnchor.constraint(equalTo: leadingAnchor),
            underlineView.trailingAnchor.constraint(equalTo: trailingAnchor),
            underlineView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 2.0),
            underlineView.heightAnchor.constraint(equalToConstant: 2.0)
        ])
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        changeColor(active: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        changeColor(active: false)
    }
    
    func changeColor(active: Bool) {
        UIView.animate(withDuration: 0.5) {
            self.underlineView.backgroundColor = active ? self.underlineActiveColor : self.underlineInactiveColor
            self.underlineView.layoutIfNeeded()
        }
    }
}

class DrinkListViewController: BaseViewController {
    
    private var disposeBag         : DisposeBag = DisposeBag()
    private var cocktailBusiness   : CocktailBusinessProtocol!
    private var favoriteBusiness   : FavoriteCocktailManager!
    
    private var listViewModel      : DrinksListViewModelProtocol!
    private var favoritesViewModel : DrinksListViewModelProtocol!
    
    private var collectionOperationSemaphore : DispatchSemaphore = DispatchSemaphore(value: 1)
    
    private var collectionData : CocktailCollectionData!
    
    private lazy var searchBar : UnderlineTextField = {
        let searchBar = UnderlineTextField()
        searchBar.underlineActiveColor = AppColors.WineRed.uiColor
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.font = AppFonts(size: 20, family: .Regular).uiFont
        
        searchBar.placeholder = "Search Drinks"
        searchBar.rx
            .text
            .bind(to: listViewModel.searchTextRelay)
            .disposed(by: disposeBag)
        
        return searchBar
    }()
    
    private lazy var collectionView : UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.delegate = self
        
        collection.dataSource = self
        return collection
    }()
    
    private weak var flowLayoutReference : SquareFlowLayout?
    
    init(navigationDelegate : CocktailNavigationDelegate, business: CocktailBusinessProtocol, favorite: FavoriteCocktailManager) {
        cocktailBusiness = business
        favoriteBusiness = favorite
        
        listViewModel = MainListViewModel(navigationDelegate: navigationDelegate)
        favoritesViewModel = FavoriteCocktailListViewModel(navigationDelegate: navigationDelegate)
        favoriteBusiness.viewModelReference = favoritesViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.addSubview(collectionView)
        view.addSubview(searchBar)
        view.backgroundColor = AppColors.BackgroundColor
        
        let navigationTitleLabel = UILabel()
        navigationTitleLabel.textColor = .white
        navigationTitleLabel.font = AppFonts(size: 30, family: .Bold).uiFont
        navigationTitleLabel.text = "Stephen"
        
        navigationItem.titleView = navigationTitleLabel
        
        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        NotificationCenter.default.rx
            .notification(UIDevice.orientationDidChangeNotification)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { _ in
                self.configureEdgeInset()
            })
            .disposed(by: disposeBag)
        
        collectionView.backgroundColor = .clear
        collectionView.register(DrinkListPreviewCell.self, forCellWithReuseIdentifier: "DrinkCell")
        collectionView.register(LoadingCell.self, forCellWithReuseIdentifier: "LoadCell")
        collectionView.register(FavoriteCocktailsCell.self, forCellWithReuseIdentifier: "FavoritesCell")
        collectionView.register(CocktailListSectionHeaderCell.self, forCellWithReuseIdentifier: "TitleHeader")
        
        listViewModel.listCollectionData
            .drive(onNext: { collectionData in
                self.collectionOperationSemaphore.wait()
                
                self.collectionData = collectionData
                
                
                let squareLayout = collectionData.isSearching ? SquareFlowLayout(delegate: self) : CustomizedSquareFlowLayout(delegate: self)
                self.collectionView.collectionViewLayout = squareLayout
                self.flowLayoutReference = squareLayout
                
                self.adaptFontChange()
                
                
                self.collectionView.reloadData()
                
                self.collectionOperationSemaphore.signal()
            })
            .disposed(by: disposeBag)
        
        listViewModel.isMakingRequest(true)
        cocktailBusiness.fetchMainCocktails { self.stopRequest(result: $0) }
        
        listViewModel.searchTextRelay
            .asObservable()
            .bind { possibleSearch in
                
                if let searchTerm = possibleSearch, !searchTerm.isEmpty {
                    self.listViewModel.isMakingRequest(true)
                    self.cocktailBusiness.searchCocktail(byName: searchTerm) { self.stopRequest(result: $0) }
                }
                
            }
            .disposed(by: disposeBag)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(adaptFontChange),
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)
        
    }
    
    private func stopRequest(result : CocktailResult) {
        self.listViewModel.isMakingRequest(false)
        
        if let error = result.error {
            print(error.description)
            
            self.showErrorMessage(title: "Ops", message: "We're having trouble fetching your cocktail details. Please try again later.") {
                self.navigationController?.popViewController(animated: true)
            }
            return
        }
        
        self.listViewModel.configureNewCocktails(result.cocktails)
    }
    
    private func configureEdgeInset() {
        self.collectionView.contentInset = UIEdgeInsets(top: self.searchBar.frame.height + 20.0,
                                                        left: self.view.safeAreaInsets.left,
                                                        bottom: 0,
                                                        right: self.view.safeAreaInsets.right )
        
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let squareLayout = collectionView.collectionViewLayout as? CustomizedSquareFlowLayout {
            squareLayout.headerReferenceSize = CGSize(width: collectionView.frame.width, height: 50)
        }
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func adaptFontChange() {
        
        var labelHeight : CGFloat = 0.0
        
        collectionData.sections.enumerated().forEach { index, section in
            switch section {
            case .Title(let string):
                
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TitleHeader", for: IndexPath(row: 0, section: index)) as? CocktailListSectionHeaderCell {
                    
                    cell.titleLabel.text = string
                    
                    if cell.titleLabel.intrinsicContentSize.height > labelHeight {
                        labelHeight = cell.titleLabel.intrinsicContentSize.height
                    }
                    
                }
            default: break
            }
        }
        
        DispatchQueue.main.async {
            
            if let customized = self.flowLayoutReference as? CustomizedSquareFlowLayout {
                customized.titleHeaderSectionHeight = labelHeight + 20.0
            }
            
            self.configureEdgeInset()
            self.flowLayoutReference?.invalidateLayout()
        }
        
    }
    
}

extension DrinkListViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return collectionData.sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionData.sections[section] {
        case .Title, .Favorite:
            return 1
        case .List:
            return collectionData.items.count
        case .RequestList:
            return 20
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch collectionData.sections[indexPath.section] {
        case .Title(let string):
            let header = collectionView.dequeueReusableCell(withReuseIdentifier: "TitleHeader", for: indexPath) as! CocktailListSectionHeaderCell
            header.titleLabel.text = string
            return header
            
        case .Favorite:
            let favoritesCell = favoritesViewModel.getCell(collectionView, indexPath: indexPath) as! FavoriteCocktailsCell
            favoritesCell.bind(favoritesViewModel)
            return favoritesCell
            
        case .List:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DrinkCell", for: indexPath) as! DrinkListPreviewCell
            cell.bind(collectionData.items[indexPath.row])
            return cell
            
        case .RequestList:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LoadCell", for: indexPath) as! LoadingCell
            cell.prepareForReuse()
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionData.sections[indexPath.section] {
        case .List: listViewModel.didSelectIndex(indexPath.row)
        default: break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "TitleHeader", for: indexPath)
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50.0)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard scrollView == collectionView else { return }
        guard !collectionData.isSearching else { return }
        
        UIView.animate(withDuration: 0.5) {
            
            if scrollView.contentOffset.y < 0 {
                self.searchBar.alpha = 1
            } else {
                self.searchBar.alpha = 0
                self.searchBar.resignFirstResponder()
            }
            
            self.searchBar.layoutIfNeeded()
        }
        
    }
}


extension DrinkListViewController : SquareFlowLayoutDelegate {
    func shouldExpandItem(at indexPath: IndexPath) -> Bool {
        guard ![UIDeviceOrientation.landscapeRight, UIDeviceOrientation.landscapeLeft].contains(UIDevice.current.orientation) else { return false }
        return indexPath.row % 2 == 0
    }
}
