//
//  OnboardingViewController.swift
//  Ungteoring
//
//  Created by Juhyeon Byun on 6/19/24.
//

import UIKit

import RxSwift
import RxCocoa

final class OnboardingViewController: UIViewController {
    
    // MARK: Properties
    
    private let viewModel: OnboardingViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: UI Component
    
    private let mainTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardB(28)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardR(16)
        label.textColor = .systemGray2
        label.numberOfLines = 2
        return label
    }()
    
    private let mainImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let pageControl = UIPageControl()
    
    private let nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("다음", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 12
        button.backgroundColor = .accent
        return button
    }()
    
    // MARK: Initailizer
    
    init(viewModel: OnboardingViewModel) {
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
        bindViewModel()
        setNotification()
    }
    
}

// MARK: - Methods

extension OnboardingViewController {
    
    private func bindUIComponents() {
        nextButton.rx.tap
            .bind(with: self) { owner, _ in
                let current = owner.viewModel.state.page.value
                
                if current < 3 {
                    owner.viewModel.state.page.accept(current + 1)
                    
                    if current == 2 {
                        owner.nextButton.setTitle("설정으로 이동", for: .normal)
                    }
                } else {
                    UIApplication.shared.open(NSURL(string:"App-prefs:root=Privacy")! as URL)
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        viewModel.state.page
            .bind(with: self) { owner, page in
                owner.pageControl.currentPage = page
                
                owner.mainImageView.image = owner.viewModel.state.images[page]
                owner.mainTitleLabel.text = owner.viewModel.state.mainTitles[page]
                owner.subTitleLabel.text = owner.viewModel.state.subTitles[page]
            }
            .disposed(by: disposeBag)
    }
    
    private func setNotification() {
        NotificationCenter
            .default
            .rx
            .notification(UIApplication.willEnterForegroundNotification)
            .subscribe(on: MainScheduler.instance)
            .subscribe(with: self) { owner, _ in
                let isPolicyOn = SensitivityAnalyzer.shared.checkPolicy()
                if isPolicyOn {
                    owner.dismiss(animated: true)
                }
            }
            .disposed(by: disposeBag)
    }
    
}

// MARK: - UI

extension OnboardingViewController {
    
    private func setUI() {
        view.backgroundColor = .black
        pageControl.numberOfPages = 4
        
        view.addSubviews([mainTitleLabel,
                          subTitleLabel,
                          mainImageView,
                          pageControl,
                          nextButton])
        
        setContrains()
    }
    
    private func setContrains() {
        mainTitleLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(30)
        }
        
        subTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(mainTitleLabel.snp.bottom).offset(14)
            make.horizontalEdges.equalTo(mainTitleLabel)
        }
        
        mainImageView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(380)
            make.top.equalTo(subTitleLabel.snp.bottom).offset(30)
        }
        
        pageControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(mainImageView.snp.bottom).offset(36)
            make.bottom.equalTo(nextButton.snp.top).offset(-39)
        }
        
        nextButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(38)
            make.horizontalEdges.equalToSuperview().inset(30)
            make.height.equalTo(60)
        }
    }
    
}
