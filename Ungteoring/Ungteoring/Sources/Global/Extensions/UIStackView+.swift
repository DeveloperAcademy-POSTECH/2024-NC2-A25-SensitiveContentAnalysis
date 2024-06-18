//
//  UIStackView+.swift
//  Ungteoring
//
//  Created by Juhyeon Byun on 6/18/24.
//

import UIKit

extension UIStackView {

    func addArrangedSubviews(_ views: [UIView]) {
        views.forEach { self.addArrangedSubview($0) }
    }
    
}
