//
//  ViewController.swift
//  Nasa
//
//  Created by Marlon Rugama on 5/31/24.
//

import UIKit

class SearchCollectionViewController: UICollectionViewController {
    
    private enum Section {
        case main
    }
    
    // MARK: - Value Types
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, String>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, String>
    
    // MARK: - Properties
    private var nasaDataSource: DataSource!
    private var viewModel: SearchViewModel
    private var searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Init
    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        
        let columns = 3.0
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0 / columns),
                                                  heightDimension: .fractionalWidth(1.0 / columns))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = .init(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .fractionalWidth(1.0 / columns))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10)
            
            return section
        }
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        DataCache.shared.clearCache()
    }
    
    // MARK: - Controller lifecyle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "NASA"
        
        configureCollectionView()
        configureSearchBar()
    }
    
    // MARK: - Private helpers
    
    private func configureCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.register(SearchCollectionViewCell.self, forCellWithReuseIdentifier: "NasaCell")
        collectionView.prefetchDataSource = self
    }
    
    private func configureDataSource() {
        let cellRegistration: UICollectionView.CellRegistration<SearchCollectionViewCell, Nasa> = .init(viewModel)
        
        nasaDataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, identifier in
            guard let nasa = self.viewModel.item(with: identifier) else { return UICollectionViewCell() }
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: nasa)
        }
    }
    
    private func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.itemIds())
        nasaDataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    private func configureSearchBar() {
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search..."
        navigationItem.searchController = searchController
    }
}

// MARK: - UISearchBarDelegate
extension SearchCollectionViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        viewModel.search(for: searchText) { [weak self] in
            self?.configureDataSource()
            self?.applySnapshot(animatingDifferences: false)
        }
    }
}

// MARK: - Delegate & DataSourcePrefetching
extension SearchCollectionViewController: UICollectionViewDataSourcePrefetching {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let identifier = nasaDataSource.itemIdentifier(for: indexPath),
              let nasa = viewModel.item(with: identifier) else { return }
        let detailVC = NasaDetailViewController(nasa: nasa)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for index in indexPaths {
            if index.row >= viewModel.nasaItems.count - 15 {
                viewModel.load() { [weak self] in
                    self?.applySnapshot()
                }
                break
            }
        }
    }
}
