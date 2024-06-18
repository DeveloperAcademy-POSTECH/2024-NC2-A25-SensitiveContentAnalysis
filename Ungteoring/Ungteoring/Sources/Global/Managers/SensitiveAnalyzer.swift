//
//  SensitiveAnalyzer.swift
//  Ungteoring
//
//  Created by Juhyeon Byun on 6/18/24.
//

import UIKit
import SensitiveContentAnalysis

final class SensitiveAnalyzer {
    
    // MARK: Properties
    
    static var shared = SensitiveAnalyzer()
    private let analyzer = SCSensitivityAnalyzer()
    
    // MARK: Methods
    
    func checkImage(with image: UIImage) async -> ImageResult {
        let policy = analyzer.analysisPolicy
        if policy == .disabled { return .error }
        
        do {
            let response = try await analyzer.analyzeImage(image.cgImage!)
            return response.isSensitive ? .sensitive : .safe
        } catch {
            return .error
        }
    }
    
}
