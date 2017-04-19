//
//  YRQRCodeRecognizer.swift
//  YRQRCode
//
//  Created by kilrae on 2017/4/17.
//  Copyright © 2017年 yang. All rights reserved.
//

import UIKit

public class YRQRCodeRecognizer: NSObject {
    public var image: CGImage? {
        didSet {
            contentArray = nil
        }
    }
    
    public var contents: [String]? {
        get {
            if nil == contentArray {
                contentArray = getQRString()
            }
            return contentArray
        }
    }
    
    private var contentArray: [String]?
    
    public init(image: CGImage) {
        self.image = image
    }
    
    private func getQRString() -> [String]? {
        guard let finalImage = self.image else {
            return nil
        }
        let result = finalImage.toCIImage().recognizeQRCode(options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        if result.isEmpty {
            return nil
        }
        return result
    }
}

public extension CGImage {
    public func toCIImage() -> CIImage {
        return CIImage(cgImage: self)
    }
}

public extension CIImage {
    func recognizeQRCode(options: [String: Any]? = nil) -> [String] {
        var result: [String] = []
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: options)
        if let features = detector?.features(in: self) {
            for feature in features {
                if let string = (feature as? CIQRCodeFeature)?.messageString {
                    result.append(string)
                }
            }
        }
        return result
    }
}
