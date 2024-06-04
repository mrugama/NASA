//
//  SearchCollectionViewCellRegistration.swift
//  Nasa
//
//  Created by Marlon Rugama on 6/3/24.
//

import UIKit

@MainActor
extension UICollectionView.CellRegistration<SearchCollectionViewCell, NasaViewModel> {
    init(_ viewModel: SearchViewModel) {
        self.init { searchCell, indexPath, nasa in
            nasa.getImage { image in
                searchCell.configure(with: image)
            }
        }
    }
}
