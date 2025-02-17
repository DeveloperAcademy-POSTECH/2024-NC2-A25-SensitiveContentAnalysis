//
//  CameraViewController.swift
//  Ungteoring
//
//  Created by Juhyeon Byun on 6/17/24.
//

import UIKit
import AVFoundation

import RxSwift
import RxCocoa
import SnapKit

final class CameraViewController: UIViewController {
    
    // MARK: Properties
    
    private let viewModel: CameraViewModel
    private let disposeBag = DisposeBag()
    private let captureSession = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    
    // MARK: UI Component
    
    private let cameraView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    
    private let flashButton: UIButton = {
        let button = UIButton()
        button.setImage(.flashOff, for: .normal)
        button.setImage(.flashOn, for: .selected)
        return button
    }()
    
    private let previewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var galleryButton = makeButton(image: .gallery)
    private lazy var cancelButton = makeButton(image: .cancel)
    private lazy var shutterButton = makeButton(image: .shutter)
    private lazy var saveButton = makeButton(image: .save)
    private lazy var changeButton = makeButton(image: .change)
    private lazy var uploadButton = makeButton(image: .upload)
    
    // MARK: Initailizer
    
    init(viewModel: CameraViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        setCamera()
        bindUIComponents()
        bindViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        showSplash()
    }
    
}

// MARK: - Methods

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    
    private func showSplash() {
        let splashViewController = SplashViewController()
        splashViewController.modalPresentationStyle = .overFullScreen
        
        //        if StorageManager.isFirstTime() {
        let onboardingViewController = OnboardingViewController(viewModel: OnboardingViewModel())
        onboardingViewController.modalPresentationStyle = .overFullScreen
        present(onboardingViewController, animated: false)
//    }
    }
    
    private func bindUIComponents() {
        flashButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.flashButton.isSelected.toggle()
                owner.flashButton.isSelected ? owner.turnOnFlash() : owner.turnOffFlash()
            }
            .disposed(by: disposeBag)
        
        galleryButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.flashButton.isSelected = false
                owner.turnOffFlash()
                
                let galleryViewController = GalleryViewController(viewModel: GalleryViewModel())
                galleryViewController.modalPresentationStyle = .overFullScreen
                owner.present(galleryViewController, animated: true)
            }
            .disposed(by: disposeBag)
        
        shutterButton.rx.tap
            .bind(with: self) { owner, _ in
                let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
                owner.photoOutput.capturePhoto(with: settings, delegate: owner)
                
                owner.flashButton.isSelected = false
            }
            .disposed(by: disposeBag)
        
        changeButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.switchCamera()
            }
            .disposed(by: disposeBag)
        
        cancelButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.viewModel.action.didCancelButtonTap.onNext(())
            }
            .disposed(by: disposeBag)
        
        saveButton.rx.tap
            .bind(with: self) { owner, _ in
                guard let image = owner.previewImageView.image else { return }
                owner.viewModel.action.didSaveButtonTap.accept(image)
            }
            .disposed(by: disposeBag)
        
        uploadButton.rx.tap
            .bind(with: self) { owner, _ in
                guard let shareImage: UIImage = owner.previewImageView.image else { return }
                var shareObject = [Any]()
                
                shareObject.append(shareImage)
                
                let activityViewController = UIActivityViewController(activityItems : shareObject, applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = owner.view
                
                owner.present(activityViewController, animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        viewModel.state.contentType
            .bind(with: self) { owner, type in
                DispatchQueue.main.async {
                    switch type {
                    case .noData:
                        [owner.galleryButton,
                         owner.shutterButton,
                         owner.changeButton].forEach { $0.isHidden = false }
                        [owner.cancelButton,
                         owner.saveButton,
                         owner.uploadButton].forEach { $0.isHidden = true }
                        
                        DispatchQueue.global(qos: .background).async {
                            owner.captureSession.startRunning()
                        }
                        
                        owner.previewImageView.isHidden = true
                        owner.removeBlurEffect()
                    case .normal:
                        [owner.galleryButton,
                         owner.shutterButton,
                         owner.changeButton].forEach { $0.isHidden = true }
                        [owner.cancelButton,
                         owner.saveButton,
                         owner.uploadButton].forEach { $0.isHidden = false }
                        
                        DispatchQueue.global(qos: .background).async {
                            owner.captureSession.stopRunning()
                        }
                        
                        owner.previewImageView.isHidden = false
                    case .sensitive:
                        [owner.galleryButton,
                         owner.cancelButton,
                         owner.shutterButton,
                         owner.saveButton,
                         owner.changeButton,
                         owner.uploadButton].forEach { $0.isHidden = true }
                        
                        DispatchQueue.global(qos: .background).async {
                            owner.captureSession.stopRunning()
                        }
                        
                        owner.previewImageView.isHidden = false
                        owner.addBlurEffect()
                        
                        owner.makeAlert() { _ in
                            owner.dismiss(animated: true)
                            owner.viewModel.action.didRetryButtonTap.onNext(())
                        }
                    }
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func addBlurEffect() {
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        visualEffectView.alpha = 1
        visualEffectView.frame = previewImageView.bounds
        visualEffectView.tag = 1
        previewImageView.addSubview(visualEffectView)
    }
    
    private func removeBlurEffect() {
        let viewWithTag = view.viewWithTag(1)
        viewWithTag?.removeFromSuperview()
    }
    
    private func setCamera() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            captureSession.addInput(videoInput)
            captureSession.addOutput(photoOutput)
        } catch {
            print("error")
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = .init(x: 0, y: 0,
                                   width: UIScreen.main.bounds.width - 32,
                                   height: (UIScreen.main.bounds.width - 32) * (4/3))
        cameraView.layer.addSublayer(previewLayer)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else { return }
        previewImageView.image = image
        viewModel.action.didShutterButtonTap.accept(image)
    }
    
    private func switchCamera() {
        captureSession.beginConfiguration()
        let currentInput = captureSession.inputs.first as? AVCaptureDeviceInput
        captureSession.removeInput(currentInput!)
        
        let newCameraDevice = currentInput?.device.position == .back ? camera(with: .front) : camera(with: .back)
        let newVideoInput = try? AVCaptureDeviceInput(device: newCameraDevice!)
        captureSession.addInput(newVideoInput!)
        captureSession.commitConfiguration()
    }
    
    private func camera(with position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: position)
        return device
    }
    
    private func turnOnFlash() {
        DispatchQueue.main.async {
            guard let device = AVCaptureDevice.default(for: .video) else { return }
            
            if device.hasTorch {
                do {
                    try device.lockForConfiguration()
                    device.torchMode = .on
                } catch {
                    print("error")
                }
            }
        }
    }
    
    private func turnOffFlash() {
        DispatchQueue.main.async {
            guard let device = AVCaptureDevice.default(for: .video) else { return }
            
            if device.hasTorch {
                do {
                    try device.lockForConfiguration()
                    device.torchMode = .off
                } catch {
                    print("error")
                }
            }
        }
    }
    
}

// MARK: - UI

extension CameraViewController {
    
    private func setUI() {
        view.backgroundColor = .black
        view.addSubviews([cameraView,
                          flashButton,
                          previewImageView,
                          galleryButton,
                          shutterButton,
                          changeButton,
                          cancelButton,
                          saveButton,
                          uploadButton])
        
        setConstraints()
    }
    
    private func setConstraints() {
        [cameraView, previewImageView].forEach { $0.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(110)
            make.height.equalTo((UIScreen.main.bounds.width - 32) * (4/3))
        }}
        
        flashButton.snp.makeConstraints { make in
            make.top.leading.equalTo(cameraView).inset(20)
        }
        
        [galleryButton, cancelButton].forEach { $0.snp.makeConstraints { make in
            make.centerY.equalTo(shutterButton)
            make.trailing.equalTo(shutterButton.snp.leading).offset(-70)
        }}
        
        [shutterButton, saveButton].forEach { $0.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(70)
        }}
        
        [changeButton, uploadButton].forEach { $0.snp.makeConstraints { make in
            make.centerY.equalTo(shutterButton)
            make.leading.equalTo(shutterButton.snp.trailing).offset(70)
        }}
    }
    
}
