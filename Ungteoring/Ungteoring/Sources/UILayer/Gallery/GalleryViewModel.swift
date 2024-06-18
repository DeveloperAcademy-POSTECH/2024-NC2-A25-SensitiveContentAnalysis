//
//  GalleryViewModel.swift
//  Ungteoring
//
//  Created by Juhyeon Byun on 6/18/24.
//

import Foundation

import RxSwift
import RxRelay

final class GalleryViewModel {
    
    // MARK: Properties
    
    private let disposeBag = DisposeBag()
    
    struct State {
//        let photos = BehaviorRelay<>
    }
    
    struct Action {
        let didCameraButtonTap = PublishSubject<Void>()
        let didAlbumButtonTap = PublishSubject<Void>()
    }
    
    let state: State
    let action: Action
    
    // MARK: Initailizer
    
    init() {
        self.state = State()
        self.action = Action()
    }
    
}
