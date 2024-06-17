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
    
    private let shutterButton: UIButton = {
        let button = UIButton()
        button.setImage(.shutter, for: .normal)
        return button
    }()
    
    private let galleryButton: UIButton = {
        let button = UIButton()
        button.setImage(.gallery, for: .normal)
        return button
    }()
    
    private let changeButton: UIButton = {
        let button = UIButton()
        button.setImage(.change, for: .normal)
        return button
    }()
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        setCamera()
        bindUIComponents()
    }
    
}

// MARK: - Methods

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    
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
    
    private func bindUIComponents() {
        galleryButton.rx.tap
            .bind(with: self) { owner, _ in
            }
            .disposed(by: self.disposeBag)
        
        shutterButton.rx.tap
            .bind(with: self) { owner, _ in
//                owner.captureSession.stopRunning()
                
                let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
                owner.photoOutput.capturePhoto(with: settings, delegate: owner)
            }
            .disposed(by: self.disposeBag)
        
        changeButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.switchCamera()
            }
            .disposed(by: self.disposeBag)
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
        self.view.addSubviews([cameraView,
                               previewImageView,
                               galleryButton,
                               shutterButton,
                               changeButton])
        
        self.setConstraints()
    }
    
    private func setConstraints() {
        cameraView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(112)
            make.height.equalTo((UIScreen.main.bounds.width - 32) * (4/3))
        }
        
        previewImageView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(112)
            make.height.equalTo((UIScreen.main.bounds.width - 32) * (4/3))
        }
        
        galleryButton.snp.makeConstraints { make in
            make.centerY.equalTo(shutterButton)
            make.trailing.equalTo(shutterButton.snp.leading).offset(-70)
        }
        
        shutterButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(70)
        }
        
        changeButton.snp.makeConstraints { make in
            make.centerY.equalTo(shutterButton)
            make.leading.equalTo(shutterButton.snp.trailing).offset(70)
        }
    }
    
}
