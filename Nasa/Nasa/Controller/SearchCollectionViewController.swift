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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "NASA"
        
        configureCollectionView()
        configureSearchBar()
    }
    
    private func configureCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.register(NasaCollectionViewCell.self, forCellWithReuseIdentifier: "NasaCell")
    }
    
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<NasaCollectionViewCell, Nasa> { cell, indexPath, nasa in
            if let nasaId = nasa.nasa_id {
                Task {
                    do {
                        let imageData = try await self.viewModel.getImageData(with: nasaId)
                        let image = UIImage(data: imageData)
                        cell.configure(with: image)
                    } catch {
                        print("Couldn't resolve image url: \(error.localizedDescription)")
                        cell.configure(with: nil)
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

extension SearchCollectionViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        Task {
            await viewModel.search(for: searchText)
            configureDataSource()
            applySnapshot()
        }
    }
}

extension Nasa: Identifiable {
    var id: String {
        UUID().uuidString
    }
}
