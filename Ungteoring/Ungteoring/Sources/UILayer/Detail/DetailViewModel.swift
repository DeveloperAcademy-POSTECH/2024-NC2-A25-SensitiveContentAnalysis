//
//  DetailViewModel.swift
//  Ungteoring
//
//  Created by Juhyeon Byun on 6/18/24.
//

import UIKit

final class DetailViewModel {
    
    // MARK: Properties
    
    struct State {
        let image: UIImage
        let dateTime: Date
    }
    
    let state: State
    
    // MARK: Initailizer
    
    init(image: UIImage, dateTime: Date) {
        self.state = State(image: image, dateTime: dateTime)
    }
    
}
