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
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(.x1 / value),
                                                  heightDimension: .fractionalWidth(.x1 / value))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = .init(all: .x2)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(.x1),
                                                   heightDimension: .fractionalWidth(.x1 / value))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = .init(all: .x10)
            
            return section
        }
    }
}

extension CGFloat {
    static let x1: CGFloat = 1.0
    static let x2: CGFloat = 2.0
    static let x4: CGFloat = 4.0
    static let x8: CGFloat = 8.0
    static let x10: CGFloat = 10.0
    static let x12: CGFloat = 12.0
    static let x14: CGFloat = 14.0
    static let x16: CGFloat = 16.0
    static let x18: CGFloat = 18.0
    static let x20: CGFloat = 20.0
    static let x24: CGFloat = 24.0
    static let x28: CGFloat = 28.0
    static let x32: CGFloat = 32.0
    static let x48: CGFloat = 48.0
    static let x64: CGFloat = 64.0
}
