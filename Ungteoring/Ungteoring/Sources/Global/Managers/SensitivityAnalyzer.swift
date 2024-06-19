//
//  SensitivityAnalyzer.swift
//  Ungteoring
//
//  Created by Juhyeon Byun on 6/19/24.
//

import UIKit
import SensitiveContentAnalysis

final class SensitivityAnalyzer {
    
    // MARK: Properties
    
    static var shared = SensitivityAnalyzer()
    private let analyzer = SCSensitivityAnalyzer()
    
    // MARK: - Methods
    
    func checkPolicy() -> Bool {
        let policy = analyzer.analysisPolicy
        return policy != .disabled
    }
    
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
