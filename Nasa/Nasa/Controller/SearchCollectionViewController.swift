//
//  ViewController.swift
//  Nasa
//
//  Created by Marlon Rugama on 5/31/24.
//

import UIKit

class SearchCollectionViewController: UICollectionViewController {
    
    private enum Section: Int {
        case main
    }
    
    private var nasaDataSource: UICollectionViewDiffableDataSource<Section, Nasa.ID>!
    private var viewModel: NasaViewModel
    private lazy var searchBar: UISearchBar = UISearchBar(frame: .init(x: 0, y: 0, width: 200, height: 20))
    
    init(viewModel: NasaViewModel) {
        self.viewModel = viewModel
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                                  heightDimension: .fractionalWidth(0.5))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = .init(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .fractionalWidth(1.0))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 2)
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10)
            
            return section
        }
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "NASA"
        
        configureCollectionView()
        configureDataSource()
        configureSearchBar()
    }
    
    private func configureCollectionView() {
        collectionView.backgroundColor = .white
    }
    
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Nasa> { cell, indexPath, nasa in
            var contentConfiguration = UIListContentConfiguration.cell()
            contentConfiguration.image = UIImage(systemName: "heart.fill")
            contentConfiguration.imageProperties.cornerRadius = 4
            contentConfiguration.imageProperties.maximumSize = .init(width: 60, height: 60)
            
            cell.contentConfiguration = contentConfiguration
        }
        
        nasaDataSource = UICollectionViewDiffableDataSource<Section, Nasa.ID>(collectionView: collectionView) { collectionView, indexPath, identifier in
            guard let nasa = self.viewModel.item(with: identifier) else { return nil }
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: nasa)
        }
    }
    
    private func loadData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Nasa.ID>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.itemIds(), toSection: .main)
        nasaDataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func configureSearchBar() {
        let search = UISearchController(searchResultsController: nil)
        search.searchBar.delegate = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Search..."
        self.navigationItem.searchController = search
    }
    
    private func updateData(with items: [Nasa]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Nasa.ID>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.itemIds(), toSection: .main)
        nasaDataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension SearchCollectionViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        viewModel.search(for: searchText)
        //print("Search button clicked with text: \(searchText)")
    }
}

extension Nasa: Identifiable {
    var id: String {
        UUID().uuidString
    }
}
