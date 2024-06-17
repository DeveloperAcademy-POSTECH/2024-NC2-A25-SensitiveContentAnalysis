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
    
    private let disposeBag = DisposeBag()
    
    struct State {
        let isSensitive = PublishRelay<Bool>()
        let photo = BehaviorRelay<UIImage?>(value: nil)
    }
    
    struct Action {
        let didShutterButtonTap = PublishSubject<Void>()
    }
    
    let state: State
    let action: Action
    
    // MARK: Initailizer
    
    init(state: State, action: Action) {
        self.state = state
        self.action = action
    }
    
}
