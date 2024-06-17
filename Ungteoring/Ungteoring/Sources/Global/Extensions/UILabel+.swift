//
//  UILabel+.swift
//  Ungteoring
//
//  Created by Juhyeon Byun on 6/17/24.
//

import UIKit

extension UILabel {
 
    // label의 height 조절
    func setLineHeight() {
        if let text = self.text {
            let lineHeight: CGFloat = self.font.pointSize + 8
            
            let style = NSMutableParagraphStyle()
            style.maximumLineHeight = lineHeight
            style.minimumLineHeight = lineHeight
            
            style.lineBreakMode = .byTruncatingTail
            style.lineBreakStrategy = .hangulWordPriority
            
            let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: style,
            .baselineOffset: (lineHeight - font.lineHeight) / 2
            ]
            
            let attributeString = NSAttributedString(string: text,
                                                     attributes: attributes)
            self.attributedText = attributeString
        }
    }

    
}
