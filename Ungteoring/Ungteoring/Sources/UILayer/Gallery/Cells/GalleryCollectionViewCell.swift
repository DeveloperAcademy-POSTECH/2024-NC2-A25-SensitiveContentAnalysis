//
//  GalleryCollectionViewCell.swift
//  Ungteoring
//
//  Created by Juhyeon Byun on 6/18/24.
//

import UIKit

final class GalleryCollectionViewCell: UICollectionViewCell {
    
    // MARK: Properties
    
    private let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .gray
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Override

    override func prepareForReuse() {
        self.resetData()
    }
}

// MARK: - Methods

extension GalleryCollectionViewCell {
    
    func setData(with image: UIImage) {
        photoImageView.image = image
    }
    
    private func resetData() {
        photoImageView.image = nil
    }
}

// MARK: - UI

extension GalleryCollectionViewCell {
    
    private func setUI() {
        contentView.addSubviews([photoImageView])
        
        setConstraints()
    }
    
    private func setConstraints() {
        photoImageView.snp.makeConstraints { make in
            make.edges.horizontalEdges.equalToSuperview()
        }
    }
}
