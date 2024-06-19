//
//  OnboardingViewModel.swift
//  Ungteoring
//
//  Created by Juhyeon Byun on 6/19/24.
//

import UIKit

import RxSwift
import RxRelay

final class OnboardingViewModel {
    
    // MARK: Properties
    
    private let disposeBag = DisposeBag()
    
    struct State {
        let page = BehaviorRelay<Int>(value: 0)
        let images: [UIImage] = [.onboarding1, .onboarding2, .onboarding3, .onboarding4]
        let mainTitles: [String] = ["오늘 운동 어땠나요?",
                                    "나도 모르게\n다른 사람이 찍혔나요?",
                                    "나의 변화한 몸을\n기록으로 남겨봐요",
                                    "엉터링 사용 전\n권한 설정이 필요해요"]
        let subTitles: [String] = ["나의 변화된 모습을\n눈치보지말고 찰칵⚡️ 찍어보세요",
                                   "민감 정보 차단 기능을 이용해\n나의 몸 변화만을 기록해보세요",
                                   "한눈에 나의 몸을\n모아서 저장해보세요",
                                   "민감한 정보를\n사전에 차단해보세요"]
    }
    
    let state: State
    
    // MARK: Initailizer
    
    init() {
        self.state = State()
    }
    
}
