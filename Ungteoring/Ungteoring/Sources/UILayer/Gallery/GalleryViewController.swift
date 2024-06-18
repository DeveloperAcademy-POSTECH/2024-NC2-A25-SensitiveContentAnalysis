//
//  GalleryViewController.swift
//  Ungteoring
//
//  Created by Juhyeon Byun on 6/18/24.
//

import UIKit

import RxSwift

final class GalleryViewController: UIViewController {
    
    // MARK: Properties
    
    private let viewModel: CameraViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: UI Component
    
    private lazy var galleryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.contentInset = .init(top: 110, left: 16, bottom: 110, right: 16)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        
        collectionView.register(GalleryCollectionViewCell.self,
                                forCellWithReuseIdentifier: GalleryCollectionViewCell.className)
        return collectionView
    }()
    
    // MARK: Initailizer
    
    init(viewModel: CameraViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension GalleryViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size: CGFloat = 111 * (UIScreen.main.bounds.width / 375)
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
}

// MARK: - UICollectionViewDataSource

extension GalleryViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GalleryCollectionViewCell.className, for: indexPath) as? GalleryCollectionViewCell else { return UICollectionViewCell() }
        
        // TODO: 데이터 넣어주기
        cell.setData(with: .shutter)
        return cell
    }
    
}

// MARK: - UI

extension GalleryViewController {
    
    private func setUI() {
        view.backgroundColor = .black
        view.addSubviews([galleryCollectionView])
        
        setConstraints()
    }
    
    private func setConstraints() {
        galleryCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}
