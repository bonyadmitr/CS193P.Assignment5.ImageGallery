//
//  ImageCell.swift
//  ImageGallery
//
//  Created by Evgeniy Ziangirov on 18/07/2018.
//  Copyright © 2018 Evgeniy Ziangirov. All rights reserved.
//

import UIKit

class BaseCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() { }
}

final class ImageCell: BaseCell {
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.text = "Can't download image"
        label.textAlignment = .center
        label.textColor = .red
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.hidesWhenStopped = true
        spinner.activityIndicatorViewStyle = .white
        return spinner
    }()
    
    private var fetchFailed = false { didSet { addErrorLabel() } }
    
    var imageURL: URL? {
        didSet {
            image = nil
            fetchImage()
        }
    }
    
    private var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
            spinner.stopAnimating()
        }
    }
    
    private func fetchImage() {
        if let url = imageURL {
            spinner.startAnimating()
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let urlContents = try? Data(contentsOf: url)
                DispatchQueue.main.async {
                    if let imageData = urlContents, url == self?.imageURL {
                        if let image = UIImage(data: imageData) {
                            self?.image = image
                        } else {
                            self?.image = nil
                            self?.fetchFailed = true
                        }
                    }
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        errorLabel.removeFromSuperview()
        image = nil
        imageURL = nil
        if imageView.image == nil {
            fetchImage()
        }
    }
    
    override func setupViews() {
        super.setupViews()
        contentView.addSubview(spinner)
        contentView.addSubview(imageView)
        contentView.activateConstraints(withVisualFormat: "H:|-2-[v0]-2-|", for: imageView)
        contentView.activateConstraints(withVisualFormat: "V:|-2-[v0]-2-|", for: imageView)
        contentView.activateConstraints(withVisualFormat: "H:|-[v0]-|", for: spinner)
        contentView.activateConstraints(withVisualFormat: "V:|-[v0]-|", for: spinner)
    }
    
    private func addErrorLabel() {
        contentView.addSubview(errorLabel)
        contentView.activateConstraints(withVisualFormat: "H:|-[v0]-|", for: errorLabel)
        contentView.activateConstraints(withVisualFormat: "V:|-[v0]-|", for: errorLabel)
    }
    
}
