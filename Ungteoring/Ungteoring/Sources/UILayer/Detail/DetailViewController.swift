//
//  DetailViewController.swift
//  Ungteoring
//
//  Created by Juhyeon Byun on 6/18/24.
//

import UIKit

import RxSwift
import RxCocoa

final class DetailViewController: UIViewController {
    
    // MARK: Properties
    
    private let viewModel: DetailViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: UI Component
    
    private let detailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .gray
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let checkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .valid
        return imageView
    }()
    
    private let dateTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardR(16)
        label.textColor = .gray
        return label
    }()
    
    private lazy var infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.alignment = .center
        stackView.addArrangedSubviews([checkImageView,
                                       dateTimeLabel])
        return stackView
    }()
    
    private lazy var galleryButton = makeButton(image: .gallery)
    private lazy var cameraButton = makeButton(image: .camera)
    private lazy var uploadButton = makeButton(image: .upload)
    
    // MARK: Initailizer
    
    init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        bindUIComponents()
    }
    
}

// MARK: - Methods

extension DetailViewController {
    
    private func bindUIComponents() {
        galleryButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        cameraButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
        
        uploadButton.rx.tap
            .bind(with: self) { owner, _ in
                print("업로드 버튼")
            }
            .disposed(by: disposeBag)
    }
    
}

// MARK: - UI

extension DetailViewController {
    
    private func setUI() {
        view.backgroundColor = .black
        view.addSubviews([detailImageView,
                          infoStackView,
                          galleryButton,
                          cameraButton,
                          uploadButton])
        
        setConstraints()
    }
    
    private func setConstraints() {
        detailImageView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(110)
            make.height.equalTo((UIScreen.main.bounds.width - 32) * (4/3))
        }
        
        infoStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(detailImageView.snp.bottom).offset(16)
        }
        
        galleryButton.snp.makeConstraints { make in
            make.centerY.equalTo(cameraButton)
            make.trailing.equalTo(cameraButton.snp.leading).offset(-70)
        }
        
        cameraButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(44)
        }
        
        uploadButton.snp.makeConstraints { make in
            make.centerY.equalTo(cameraButton)
            make.leading.equalTo(cameraButton.snp.trailing).offset(70)
        }
    }
    
}
