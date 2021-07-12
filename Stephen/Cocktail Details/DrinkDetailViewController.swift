//
//  DrinkDetailViewController.swift
//  Stephen
//
//  Created by João Leite on 30/06/21.
//

import UIKit
import RxSwift

class DrinkDetailViewController: BaseViewController {
    
    private var disposeBag : DisposeBag = DisposeBag()
    
    private var viewModel : DrinkDetailViewModelProtocol!
    private var business  : CocktailBusinessProtocol!
    private var favorite  : FavoriteCocktailManager!
    
    private var navigationDelegate : CocktailNavigationDelegate!
    
    private lazy var previewImage : UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        return image
    }()
    
    private var cocktailNameLabel : UILabel = {
        let cocktailNameLabel = UILabel()
        cocktailNameLabel.translatesAutoresizingMaskIntoConstraints = false
        cocktailNameLabel.textColor = .white
        cocktailNameLabel.numberOfLines = 0

        cocktailNameLabel.font = AppFonts(size: 25, family: .Bold).uiFont
        
        return cocktailNameLabel
    }()
    
    private lazy var tagsCollectionView : UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: .init())
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = .clear
        collection.register(CocktailTagCell.self, forCellWithReuseIdentifier: "TagCell")
        collection.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        collection.showsHorizontalScrollIndicator = false
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10.0
        
        collection.collectionViewLayout = layout

        viewModel.drinkTagsDriver
            .drive(collection.rx.items(cellIdentifier: "TagCell", cellType: CocktailTagCell.self)) { _, tag, cell in
                cell.prepareForReuse()
                cell.tagLabel.text = tag
            }
            .disposed(by: disposeBag)
        
        collection.delegate = self
        
        return collection
    }()
    
    private lazy var cocktailHeaderView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = AppColors.WineRed.uiColor
        
        view.addSubview(previewImage)
        view.addSubview(cocktailNameLabel)
        view.addSubview(tagsCollectionView)
        
        view.constraintToEdges(previewImage)
        
        NSLayoutConstraint.activate([
            cocktailNameLabel.leadingAnchor.constraint(equalTo: previewImage.safeAreaLayoutGuide.leadingAnchor, constant: 20.0),
            cocktailNameLabel.trailingAnchor.constraint(equalTo: previewImage.safeAreaLayoutGuide.trailingAnchor, constant: -10.0),
            cocktailNameLabel.bottomAnchor.constraint(equalTo: tagsCollectionView.topAnchor),
            
            tagsCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tagsCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tagsCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
        ])
        
        return view
    }()
    
    private var collectionHeightConstraint : NSLayoutConstraint!
    
    private lazy var informationTableView : UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .clear
        table.separatorColor = .clear
        table.allowsSelection = false
        table.register(CocktailInstructionCell.self, forCellReuseIdentifier: "InstructionCell")
        table.contentInset = UIEdgeInsets(top: 300, left: 0, bottom: 0, right: 0)
        table.showsVerticalScrollIndicator = false
        return table
    }()
    
    init(navigationDelegate nd: CocktailNavigationDelegate, cocktail c: Cocktail, businessProtocol: CocktailBusinessProtocol, favoriteProtocol: FavoriteCocktailManager) {
        super.init(nibName: nil, bundle: nil)
        viewModel = DrinkDetailViewModel(cocktail: c)
        navigationDelegate = nd
        business = businessProtocol
        favorite = favoriteProtocol
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func exitButtonPress() {
        navigationDelegate.goBack()
    }
    
    private lazy var favoriteImageView : UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: favorite.isFavoriteCocktail(id: viewModel.cocktail.id) ? "star.fill" : "star")!)
        imageView.contentMode = .scaleAspectFill
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(favoriteButtonPress)))
        imageView.tintColor = .white
        
        return imageView
    }()
    
    @objc func favoriteButtonPress() {
        favorite.isFavoriteCocktail(id: viewModel.cocktail.id) ?
            favorite.removeCocktail(viewModel.cocktail) :
            favorite.saveNewCocktail(viewModel.cocktail)
        
        favoriteImageView.image = UIImage(systemName: favorite.isFavoriteCocktail(id: viewModel.cocktail.id) ? "star.fill" : "star")!
    }
    
    var tableHeightConstraint : NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let backImageView = UIImageView(image: UIImage(systemName: "arrow.backward.circle.fill"))
        backImageView.contentMode = .scaleAspectFill
        backImageView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        backImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(exitButtonPress)))
        backImageView.tintColor = .white
        let backItem = UIBarButtonItem(customView: backImageView)

        navigationItem.backBarButtonItem = nil
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = backItem
        
        let navigationBarAppearence = UINavigationBarAppearance()
        navigationBarAppearence.shadowColor = .clear
        navigationBarAppearence.backgroundColor = AppColors.WineRed.uiColor
        
        navigationController?.navigationBar.barTintColor = AppColors.WineRed.uiColor
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        favoriteImageView.frame = backImageView.frame
        let favoriteButton = UIBarButtonItem(customView: favoriteImageView)
        navigationItem.rightBarButtonItem = favoriteButton
        
        view.backgroundColor = AppColors.BackgroundColor
        view.addSubview(informationTableView)
        
        NSLayoutConstraint.activate([
            informationTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            informationTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10.0),
            informationTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            informationTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
        
        view.addSubview(cocktailHeaderView)
        tableHeightConstraint = cocktailHeaderView.heightAnchor.constraint(equalToConstant: 300)
        tableHeightConstraint.isActive = true
        cocktailHeaderView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        collectionHeightConstraint = tagsCollectionView.heightAnchor.constraint(equalToConstant: 0.0)
        
        NSLayoutConstraint.activate([collectionHeightConstraint])
        
        bind()
        
        showLoading()
        
        business.fetchCocktailDetails(viewModel.cocktail) { possibleError in
            
            if let error = possibleError {
                print(error.description)
                
                self.showErrorMessage(title: "Ops", message: "We're having trouble fetching your cocktail details. Please try again later.") {
                    self.navigationController?.popViewController(animated: true)
                }
                return
            }

            DispatchQueue.main.async {
                self.hideLoading()
                self.viewModel.refreshInformation()
                self.informationTableView.delegate = self
                self.informationTableView.dataSource = self
                self.informationTableView.reloadData()
            }

            
        }
    }
    
    func bind() {
        
        viewModel.nameDriver
            .drive(cocktailNameLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.imageURLDriver
            .drive(onNext: {
                self.previewImage.kf.setImage(with: $0)
            })
            .disposed(by: disposeBag)
        
        viewModel.dataErrorPublisher
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: {
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.drinkTagsDriver
            .drive(onNext: { tags in
                self.collectionHeightConstraint.constant = tags.isEmpty ? 0.0 : 50.0
            })
            .disposed(by: disposeBag)
        
        
    }
}

extension DrinkDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return viewModel.getTagItemSize(index: indexPath.row)
    }
}

extension DrinkDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return viewModel.cocktailIngredients.count + 1
        case 1: return viewModel.cocktailInstructions.count + 1
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "defaultCell")
            cell.backgroundColor = .clear
            
            if let textLabel = cell.textLabel {
                AppFonts(family: .Bold, uiFontStyle: .title1).configure(textLabel)
                textLabel.text = indexPath.section == 0 ? "What you'll need:" : "What to do:"
                textLabel.textColor = AppColors.TextColor
            }
            
            return cell
        }
                
        switch indexPath.section {
        case 0:
            
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
            let ingredient = viewModel.cocktailIngredients[indexPath.row - 1]
            cell.backgroundColor = .clear
            cell.accessoryView = nil
            
            if let textLabel = cell.textLabel {
                textLabel.text = ingredient.name
                textLabel.textColor = AppColors.TextColor
                AppFonts(family: .Bold, uiFontStyle: .callout).configure(textLabel)
            }
            
            if let textLabel = cell.detailTextLabel {
                textLabel.text = ingredient.quantity
                textLabel.textColor = AppColors.TextColor
                AppFonts(family: .Regular, uiFontStyle: .body).configure(textLabel)
            }
            
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "InstructionCell", for: indexPath) as! CocktailInstructionCell
            let instruction = viewModel.cocktailInstructions[indexPath.row - 1]
            
            cell.fillInfo(instruction: instruction,
                          step: { () -> CocktailInstructionCell.InstructionStep in
                            
                            if viewModel.cocktailInstructions.count == 1 {
                                return .Unique
                            } else if viewModel.cocktailInstructions.first == instruction {
                                return .Start
                            } else if viewModel.cocktailInstructions.last == instruction {
                                return .End
                            } else {
                                return .Middle
                            }
                            
                          }(), index: indexPath.row - 1)
            
            cell.detailTextLabel?.text = nil
            return cell
            
        default: fatalError("Number of details sections is poorly configured.")
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard scrollView == informationTableView else { return }
        let minHeight = (cocktailNameLabel.frame.height + collectionHeightConstraint.constant) + 20
        guard minHeight > 20 else { return }
        
        let y = 300 - (scrollView.contentOffset.y + 300)
        let height = min(max(y, minHeight), 400)
        tableHeightConstraint.constant = height
        previewImage.alpha = height <= minHeight ? 0 : height / 300
    }
    
}


