//
//  DrinkListViewController.swift
//  Stephen
//
//  Created by João Leite on 29/06/21.
//

import UIKit
import RxSwift
import RxCocoa

class DrinkListViewController: BaseViewController {
    
    private var disposeBag         : DisposeBag = DisposeBag()
    private var cocktailBusiness   : CocktailBusinessProtocol!
    private var favoriteBusiness   : FavoriteCocktailManager!
    
    private var listViewModel      : DrinksListViewModelProtocol!
    private var favoritesViewModel : DrinksListViewModelProtocol!
    
    enum CollectionSections {
        case Title(String), Favorite, List
    }
    
    private var currentSections : [CollectionSections] = [.Title("My Favorite Cocktails"),
                                                          .Favorite,
                                                          .Title("New Suggestions"),
                                                          .List]
    
    private lazy var collectionView : UICollectionView = {
        let squareLayout = SquareFlowLayout()
        squareLayout.interSpacing = 5.0
        squareLayout.flowDelegate = self
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: squareLayout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.delegate = self
        
        collection.dataSource = self
        return collection
    }()
    
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
        view.backgroundColor = AppColors.BackgroundColor
        
        let navigationTitleLabel = UILabel()
        navigationTitleLabel.textColor = .white
        navigationTitleLabel.font = AppFonts(size: 30, family: .Bold).uiFont
        navigationTitleLabel.text = "Stephen"
        
        navigationItem.titleView = navigationTitleLabel
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        NotificationCenter.default.rx
            .notification(UIDevice.orientationDidChangeNotification)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { _ in
                
                var edgeInsetMargin : CGFloat = 10.0
                
                if [UIDeviceOrientation.landscapeRight, UIDeviceOrientation.landscapeLeft].contains(UIDevice.current.orientation) {
                    edgeInsetMargin = 0.0
                }
                
                self.collectionView.contentInset = UIEdgeInsets(top: 0,
                                                                left: self.view.safeAreaInsets.left + edgeInsetMargin,
                                                                bottom: 0,
                                                                right: self.view.safeAreaInsets.right + edgeInsetMargin)
                
                self.collectionView.collectionViewLayout.invalidateLayout()
            })
            .disposed(by: disposeBag)
        
        collectionView.backgroundColor = .clear
        collectionView.register(DrinkListPreviewCell.self, forCellWithReuseIdentifier: "DrinkCell")
        collectionView.register(LoadingCell.self, forCellWithReuseIdentifier: "LoadCell")
        collectionView.register(FavoriteCocktailsCell.self, forCellWithReuseIdentifier: "FavoritesCell")
        collectionView.register(CocktailListSectionHeaderCell.self, forCellWithReuseIdentifier: "TitleHeader")
        
        listViewModel.cocktailListDriver
            .drive(onNext: { _ in
                self.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
        
        listViewModel.isMakingRequest(true)
        cocktailBusiness.fetchMainCocktails { result in
            
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
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
         
        if let squareLayout = collectionView.collectionViewLayout as? SquareFlowLayout {
            squareLayout.headerReferenceSize = CGSize(width: collectionView.frame.width, height: 50)
        }
        
    }
    
}

extension DrinkListViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return currentSections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch currentSections[section] {
        case .Title, .Favorite:
            return 1
        case .List:
            return listViewModel.drinksCount
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch currentSections[indexPath.section] {
        case .Title(let string):
            let header = collectionView.dequeueReusableCell(withReuseIdentifier: "TitleHeader", for: indexPath) as! CocktailListSectionHeaderCell
            header.titleLabel.text = string
            return header
            
        case .Favorite:
            let favoritesCell = favoritesViewModel.getCell(collectionView, indexPath: indexPath) as! FavoriteCocktailsCell
            favoritesCell.bind(favoritesViewModel)
            return favoritesCell
            
        case .List: return listViewModel.getCell(collectionView, indexPath: indexPath)
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch currentSections[indexPath.section] {
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
}


extension DrinkListViewController : SquareFlowLayoutDelegate {
    func shouldExpandItem(at indexPath: IndexPath) -> Bool {
        guard ![UIDeviceOrientation.landscapeRight, UIDeviceOrientation.landscapeLeft].contains(UIDevice.current.orientation) else { return false }
        return indexPath.row % 2 == 0
    }
}
