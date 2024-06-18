//
//  CameraViewModel.swift
//  Ungteoring
//
//  Created by Juhyeon Byun on 6/17/24.
//

import UIKit

import RxSwift
import RxRelay

final class CameraViewModel {
    
    // MARK: Properties
    
    enum ContentType {
        case noData
        case normal
        case sensitive
    }
    
    private let disposeBag = DisposeBag()
    
    struct State {
        let contentType = BehaviorRelay<ContentType>(value: .noData)
    }
    
    struct Action {
        let didShutterButtonTap = PublishRelay<UIImage>()
        let didSaveButtonTap = PublishSubject<Void>()
        let didCancelButtonTap = PublishSubject<Void>()
        let didRetryButtonTap = PublishSubject<Void>()
    }
    
    let state: State
    let action: Action
    
    // MARK: Initailizer
    
    init() {
        self.state = State()
        self.action = Action()
        
        bindAction()
    }
    
}

// MARK: - Methods

extension CameraViewModel {
    
    private func bindAction() {
        action.didShutterButtonTap
            .bind(with: self) { owner, image in
                Task { @MainActor in
                    let result = await SensitivityAnalyzer.shared.checkImage(with: image)
                    
                    switch result {
                    case .safe:
                        owner.state.contentType.accept(.normal)
                    case .sensitive:
                        owner.state.contentType.accept(.sensitive)
                    case .error:
                        owner.state.contentType.accept(.noData)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        action.didSaveButtonTap
            .bind(with: self) { owner, _ in
                // data 저장
            }
            .disposed(by: disposeBag)
        
        action.didCancelButtonTap
            .bind(with: self) { owner, _ in
                owner.state.contentType.accept(.noData)
            }
            .disposed(by: disposeBag)
        
        action.didRetryButtonTap
            .bind(with: self) { owner, _ in
                owner.state.contentType.accept(.noData)
            }
            .disposed(by: disposeBag)
    }
    
}
