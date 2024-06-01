//
//  NasaDetailViewController.swift
//  Nasa
//
//  Created by Marlon Rugama on 6/1/24.
//

import UIKit

class NasaDetailViewController: UIViewController, UIScrollViewDelegate {
    
    private enum IconType: String {
        case person = "person", location = "mappin.and.ellipse"
        
        var systemImage: UIImage? {
            return UIImage(systemName: self.rawValue)
        }
    }
    
    private let nasa: Nasa
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.numberOfLines = 0
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    private let photographerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private var imageViewHeightConstraint: NSLayoutConstraint!
    
    init(nasa: Nasa) {
        self.nasa = nasa
        if let urlStr = nasa.href, let imageData = DataCache.shared.getData(for: urlStr) {
            self.imageView.image = UIImage(data: imageData)
        }
        super.init(nibName: nil, bundle: nil)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Detail"
    }
    
    private func configureUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(photographerLabel)
        contentView.addSubview(locationLabel)
        contentView.addSubview(descriptionLabel)
        
        scrollView.delegate = self
        
        imageViewHeightConstraint = imageView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            imageViewHeightConstraint,
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            photographerLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            photographerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            photographerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            locationLabel.topAnchor.constraint(equalTo: photographerLabel.bottomAnchor, constant: 5),
            locationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            locationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        
        titleLabel.text = nasa.title
        descriptionLabel.text = nasa.description ?? nasa.description_508 ?? "No info"
        photographerLabel.attributedText = decorateText(with: .person, text: (nasa.photographer ?? "-") ?? "-")
        locationLabel.attributedText = decorateText(with: .location, text: (nasa.location ?? "-") ?? "-")
    }
    
    // MARK: - Helper methods
    
    private func decorateText(with icon: IconType, text: String) -> NSAttributedString {
        guard let image = icon.systemImage else {
            return NSAttributedString(string: text)
        }
        let attachment = NSTextAttachment()
        attachment.image = image.withRenderingMode(.alwaysTemplate)
        let imageOffsetY: CGFloat = -2.0
        attachment.bounds = CGRect(x: 0, y: imageOffsetY, width: 16, height: 16)
        
        let attachmentString = NSAttributedString(attachment: attachment)
        let completeText = NSMutableAttributedString(string: " ")
        completeText.append(attachmentString)
        completeText.append(NSAttributedString(string: " \(text)"))
        
        return completeText
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        let scale = max(0.5, 1 - yOffset / 200)
        
        imageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        
        if yOffset > 150 {
            navigationItem.title = nasa.title
        } else {
            navigationItem.title = "Detail"
        }
    }
}
