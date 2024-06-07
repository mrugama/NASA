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
    
    private let nasa: NasaViewModel
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = .x10
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: .x24)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: .x16)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var photographerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: .x16)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: .x16)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private var imageViewHeightConstraint: NSLayoutConstraint!
    
    init(nasa: NasaViewModel) {
        self.nasa = nasa
        super.init(nibName: nil, bundle: nil)
        
        nasa.getImage { [weak self] image in
            self?.imageView.image = image
        }
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
            
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: .x24),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: .x24),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -.x24),
            imageViewHeightConstraint,
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: .x24),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: .x24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -.x24),
            
            photographerLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: .x10),
            photographerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: .x24),
            photographerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -.x24),
            
            locationLabel.topAnchor.constraint(equalTo: photographerLabel.bottomAnchor, constant: .x4),
            locationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: .x24),
            locationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -.x24),
            
            descriptionLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: .x10),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: .x24),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -.x24),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -.x24)
        ])
        
        titleLabel.text = nasa.title
        descriptionLabel.text = nasa.description
        photographerLabel.attributedText = decorateText(with: .person, text: nasa.photographer)
        locationLabel.attributedText = decorateText(with: .location, text: nasa.location)
    }
    
    // MARK: - Helper methods
    
    private func decorateText(with icon: IconType, text: String) -> NSAttributedString {
        guard let image = icon.systemImage else {
            return NSAttributedString(string: text)
        }
        let attachment = NSTextAttachment()
        attachment.image = image.withRenderingMode(.alwaysTemplate)
        let imageOffsetY: CGFloat = -.x2
        attachment.bounds = CGRect(x: 0, y: imageOffsetY, width: .x16, height: .x16)
        
        let attachmentString = NSAttributedString(attachment: attachment)
        let completeText = NSMutableAttributedString(string: " ")
        completeText.append(attachmentString)
        completeText.append(NSAttributedString(string: " \(text)"))
        
        return completeText
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        let scale = max(0.5, .x1 - yOffset / 200)
        
        imageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        
        if yOffset > 150 {
            navigationItem.title = nasa.title
        } else {
            navigationItem.title = "Detail"
        }
    }
}
