//
//  UIViewController+.swift
//  Ungteoring
//
//  Created by Juhyeon Byun on 6/18/24.
//

import UIKit

extension UIViewController {
    
    func makeButton(image: UIImage) -> UIButton {
        let button = UIButton()
        button.setImage(image, for: .normal)
        return button
    }
    
    ///  버튼 Alert 메서드
    func makeAlert(
        title : String = "민감 정보 차단",
        message : String? = "다음 사진은 민감 정보가 포함되어 있습니다.\n다시 업로드 바랍니다.",
        okTitle: String = "다시 업로드",
        okAction : ((UIAlertAction) -> Void)? = nil,
        completion : (() -> Void)? = nil
    ) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        let alertViewController = UIAlertController(
            title: title, message: message,
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: okTitle, style: .destructive, handler: okAction)
        alertViewController.addAction(okAction)
        self.present(alertViewController, animated: true, completion: completion)
    }
    
}
