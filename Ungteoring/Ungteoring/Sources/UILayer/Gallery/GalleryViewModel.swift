//
//  GalleryViewModel.swift
//  Ungteoring
//
//  Created by Juhyeon Byun on 6/18/24.
//

import Foundation
import CoreData

import RxSwift
import RxRelay

final class GalleryViewModel {
    
    // MARK: Properties
    
    private let disposeBag = DisposeBag()
    
    struct State {
        let photos = BehaviorRelay<[NSManagedObject]>(value: [])
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

// MARK: - Methods

extension GalleryViewModel {
    
    func fetchPhotos() {
        let photoFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Photo")
        let photos = CoreDataManager.shared.fetchContext(request: photoFetchRequest)
        state.photos.accept(photos.reversed())
    }
    
}
