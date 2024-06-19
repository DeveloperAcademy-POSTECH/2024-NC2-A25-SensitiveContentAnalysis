//
//  SplashViewController.swift
//  Ungteoring
//
//  Created by Juhyeon Byun on 6/19/24.
//

import UIKit
import Lottie

final class SplashViewController: UIViewController {
    
    // MARK: UI Component
    
    private let animationView: LottieAnimationView = .init(name: "mp4convert")
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        view.addSubview(animationView)
        
        animationView.frame = view.bounds
        animationView.center = view.center
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .repeat(1)
        animationView.play()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if StorageManager.isFirstTime() {
                let onboardingViewController = OnboardingViewController(viewModel: OnboardingViewModel())
                guard let pvc = self.presentingViewController else { return }

                self.dismiss(animated: true) {
                  pvc.present(onboardingViewController, animated: false, completion: nil)
                }
            } else {
                self.dismiss(animated: true)
            }
        }
    }
    
}
