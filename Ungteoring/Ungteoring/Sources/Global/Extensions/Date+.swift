//
//  Date+.swift
//  Ungteoring
//
//  Created by Juhyeon Byun on 6/17/24.
//

import Foundation

enum DateFormatType: String {
    case dateDayTime = "yyyy.MM.dd HH:mm"
}

extension DateFormatType {
    
    var formatter: DateFormatter {
        guard let formatter = DateFormatType.cachedFormatters[self] else {
            let generatedFormatter = DateFormatType.makeFormatter(withDateFormat: self)
            DateFormatType.cachedFormatters[self] = generatedFormatter
            return generatedFormatter
        }
        
        return formatter
    }
    
    private static var cachedFormatters: [DateFormatType: DateFormatter] = [:]
    
    private static func makeFormatter(withDateFormat dateFormatType: DateFormatType) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormatType.rawValue
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }
    
}

extension Date {
    
    func format(_ formatType: DateFormatType) -> String {
        let offsetComps = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute], from: self, to: Date())
        
        if case let (h?, m?) = (offsetComps.hour, offsetComps.minute) {
            if h == 0 {
                if m == 0 {
                    return "방금 전"
                } else {
                    return "\(m)분 전"
                }
            } else if h < 24 {
                return "\(h)시간 전"
            } else {
                return formatType.formatter.string(from: self)
            }
        }
        
        return "-"
    }

}
