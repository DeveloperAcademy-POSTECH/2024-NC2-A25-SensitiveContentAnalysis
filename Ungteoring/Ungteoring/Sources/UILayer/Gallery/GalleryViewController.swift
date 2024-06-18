//
//  GalleryViewController.swift
//  Ungteoring
//
//  Created by Juhyeon Byun on 6/18/24.
//

import UIKit

import RxSwift
import RxCocoa

final class GalleryViewController: UIViewController {
    
    // MARK: Properties
    
    private let viewModel: CameraViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: UI Component

    private lazy var galleryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.contentInset = .init(top: 16, left: 16, bottom: 80, right: 16)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        
        collectionView.register(GalleryCollectionViewCell.self,
                                forCellWithReuseIdentifier: GalleryCollectionViewCell.className)
        return collectionView
    }()
    
    private lazy var cameraButton = makeButton(image: .camera)
    private lazy var albumButton = makeButton(image: .album)
    
    private lazy var gradientBottomView: UIView = {
        let view = UIView()

        let gradient = CAGradientLayer()
        gradient.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 110)
        gradient.colors = [UIColor.black.withAlphaComponent(0.0).cgColor,
                           UIColor.black.cgColor]
        view.layer.insertSublayer(gradient, at: 0)

        return view
    }()
    
    // MARK: Initailizer
    
    init(viewModel: CameraViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        setUI()
        bindUIComponents()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
}

// MARK: - Methods

extension GalleryViewController {
    
    private func bindUIComponents() {
        cameraButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        albumButton.rx.tap
            .bind(with: self) { owner, _ in
                let picker = UIImagePickerController()
                picker.delegate = owner
                picker.sourceType = .photoLibrary
                owner.present(picker, animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
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

// MARK: - UIImagePickerController Delegate

extension GalleryViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.dismiss(animated: false, completion: {
                DispatchQueue.main.async {
                    // TODO: - 이미지 데이터 내장 데이터에 추가
                    self.galleryCollectionView.reloadData()
                }
            })
        }
    }
    
}

// MARK: - UI

extension GalleryViewController {
    
    private func setUI() {
        view.backgroundColor = .black
        view.addSubviews([galleryCollectionView,
                          gradientBottomView,
                          cameraButton,
                          albumButton])
        
        setConstraints()
    }
    
    private func setConstraints() {
        galleryCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        gradientBottomView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(110)
        }
        
        cameraButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(44)
        }
        
        albumButton.snp.makeConstraints { make in
            make.centerY.equalTo(cameraButton)
            make.leading.equalTo(cameraButton.snp.trailing).offset(70)
        }
    }
    
}
