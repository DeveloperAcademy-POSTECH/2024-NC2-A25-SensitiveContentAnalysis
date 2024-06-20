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
    
    private let gifImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        setGIF()
        changeRoot()
    }
    
}

// MARK: - Methods

extension SplashViewController {
    
    private func changeRoot() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            let mainViewController = CameraViewController(viewModel: CameraViewModel())
            let navigationController = UINavigationController(rootViewController: mainViewController)
            
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootVC(navigationController, animated: false)
        }
    }
    
    private func setGIF() {
        guard
            let gifURL = Bundle.main.url(forResource: "splash", withExtension: "gif"),
            let gifData = try? Data(contentsOf: gifURL),
            let source = CGImageSourceCreateWithData(gifData as CFData, nil)
        else { return }
        
        let frameCount = CGImageSourceGetCount(source)
        var images = [UIImage]()
        
        (0..<frameCount)
            .compactMap { CGImageSourceCreateImageAtIndex(source, $0, nil) }
            .forEach { images.append(UIImage(cgImage: $0)) }
        
        gifImageView.animationImages = images
        gifImageView.animationDuration = TimeInterval(frameCount) * 0.05
        gifImageView.animationRepeatCount = 0
        gifImageView.startAnimating()
    }
    
}

// MARK: - UI

extension SplashViewController {
    
    private func setUI() {
        view.addSubview(gifImageView)
        view.backgroundColor = .black
        
        setConstraints()
    }
    
    private func setConstraints() {
        gifImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
