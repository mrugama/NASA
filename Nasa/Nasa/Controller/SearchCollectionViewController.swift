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
    private var viewModel: NasaViewModel
    private var searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Init
    init(viewModel: NasaViewModel) {
        self.viewModel = viewModel
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0 / 3),
                                                  heightDimension: .fractionalWidth(1.0 / 3))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = .init(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .fractionalWidth(1.0 / 3.0))
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
        collectionView.register(NasaCollectionViewCell.self, forCellWithReuseIdentifier: "NasaCell")
        collectionView.prefetchDataSource = self
    }
    
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<NasaCollectionViewCell, Nasa> { cell, indexPath, nasa in
            if let nasaId = nasa.nasa_id {
                self.viewModel.getImageData(with: nasaId) { result in
                    switch result {
                    case .success(let data):
                        let image = UIImage(data: data)
                        cell.configure(with: image)
                    case .failure(let error):
                        return
                    }
                }
            }
        }
        
        nasaDataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, identifier in
            guard let nasa = self.viewModel.item(with: identifier)
            else {
                return collectionView.dequeueReusableCell(withReuseIdentifier: "NasaCell", for: indexPath)
            }
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: nasa)
        }
    }
    
    private func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.itemIds(), toSection: .main)
        nasaDataSource.apply(snapshot, animatingDifferences: true)
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
            self?.applySnapshot()
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
