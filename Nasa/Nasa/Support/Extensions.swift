//
//  Extensions.swift
//  Nasa
//
//  Created by Marlon Rugama on 6/3/24.
//

import UIKit

extension NSDirectionalEdgeInsets {
    init(all value: CGFloat) {
        self.init(top: value, leading: value, bottom: value, trailing: value)
    }
}

extension UICollectionViewCompositionalLayout {
    convenience init(columns value: CGFloat) {
        self.init { (sectionIndex, environment) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0 / value),
                                                  heightDimension: .fractionalWidth(1.0 / value))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = .init(all: 2.0)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .fractionalWidth(1.0 / value))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = .init(all: 10.0)
            
            return section
        }
    }
}
