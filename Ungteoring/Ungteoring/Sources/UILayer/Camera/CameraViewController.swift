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
    
    private let previewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .shutter
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.isHidden = true
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
    
}

// MARK: - Methods

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    
    private func bindUIComponents() {
        galleryButton.rx.tap
            .bind(with: self) { owner, _ in
                let galleryViewController = GalleryViewController(viewModel: CameraViewModel())
                galleryViewController.modalPresentationStyle = .overFullScreen
                owner.present(galleryViewController, animated: true)
            }
            .disposed(by: disposeBag)
        
        shutterButton.rx.tap
            .bind(with: self) { owner, _ in
                let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
                owner.photoOutput.capturePhoto(with: settings, delegate: owner)
                owner.viewModel.action.didShutterButtonTap.onNext(())
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
                owner.previewImageView.isHidden = true
            }
            .disposed(by: disposeBag)
        
        saveButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.viewModel.action.didSaveButtonTap.onNext(())
            }
            .disposed(by: disposeBag)
        
        uploadButton.rx.tap
            .bind(with: self) { owner, _ in
                // 공유하기
            }
            .disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        viewModel.state.contentType
            .bind(with: self) { owner, type in
                switch type {
                case .noData:
                    [owner.galleryButton,
                     owner.shutterButton,
                     owner.changeButton].forEach { $0.isHidden = false }
                    [owner.cancelButton,
                     owner.saveButton,
                     owner.uploadButton].forEach { $0.isHidden = true }
                case .normal:
                    [owner.galleryButton,
                     owner.shutterButton,
                     owner.changeButton].forEach { $0.isHidden = true }
                    [owner.cancelButton,
                     owner.saveButton,
                     owner.uploadButton].forEach { $0.isHidden = false }
                case .sensitive:
                    [owner.galleryButton,
                     owner.cancelButton,
                     owner.shutterButton,
                     owner.saveButton,
                     owner.changeButton,
                     owner.uploadButton].forEach { $0.isHidden = true }
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func makeButton(image: UIImage) -> UIButton {
        let button = UIButton()
        button.setImage(image, for: .normal)
        return button
    }
    
    private func setCamera() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            captureSession.addInput(videoInput)
            captureSession.addOutput(photoOutput)
        } catch {
            // 에러 처리
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = .init(x: 0, y: 0,
                                   width: UIScreen.main.bounds.width - 32,
                                   height: (UIScreen.main.bounds.width - 32) * (4/3))
        cameraView.layer.addSublayer(previewLayer)
        
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        let image = UIImage(data: imageData)
        previewImageView.image = image
        previewImageView.isHidden = false
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
    
}

// MARK: - UI

extension CameraViewController {
    
    private func setUI() {
        view.backgroundColor = .black
        view.addSubviews([cameraView,
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
