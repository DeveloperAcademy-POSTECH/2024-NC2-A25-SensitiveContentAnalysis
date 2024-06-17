//
//  UIView+.swift
//  Ungteoring
//
//  Created by Juhyeon Byun on 6/17/24.
//

import UIKit

extension UIView {
    
    func addSubviews(_ views: [UIView]) {
        views.forEach { self.addSubview($0) }
    }
}
