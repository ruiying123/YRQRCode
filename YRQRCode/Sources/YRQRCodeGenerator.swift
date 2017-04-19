//
//  YRQRCodeGenerator.swift
//  YRQRCode
//
//  Created by kilrae on 2017/4/17.
//  Copyright © 2017年 yang. All rights reserved.
//

import UIKit

public class YRQRCodeGenerator: NSObject {
    
    // MARK: - Parameters
    public var content: String? {
        didSet {
            imageQRCode = nil
        }
    }
    
//    public var inputCorrectionLevel {
//        
//    }
    
    public var size: CGFloat? {
        didSet {
            imageQRCode = nil
        }
    }
    
    public var icon: UIImage? = nil {
        didSet {
            imageQRCode = nil
        }
    }
    
    public var image: UIImage? {
        get {
            if nil == imageQRCode {
                imageQRCode = createImageQRCode()
            }
            return imageQRCode
        }
    }
    
    private var imageQRCode: UIImage?
    
    public init(content: String?, size: CGFloat?, icon: UIImage?) {
        self.content = content
        self.size = size
        self.icon = icon
    }
    
    private func createImageQRCode() -> UIImage? {
        let finalIcon = self.icon
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setDefaults()
        let data = content?.data(using: .utf8)
        filter?.setValue(data, forKey: "inputMessage")
        filter?.setValue("M", forKey: "inputCorrectionLevel")
        let outImage = filter?.outputImage
        let outWidth = outImage?.extent.size.width
        let scalImage = outImage?.applying(CGAffineTransform(scaleX: size!/outWidth!, y: size!/outWidth!))
        var finalImage: UIImage = UIImage(ciImage: scalImage!)
        if finalIcon != nil {
            finalImage = self.iconQRCode(outImage: scalImage!)
        }
        return finalImage
    }
    
    private func iconQRCode(outImage: CIImage) -> UIImage {
        var finalImage = UIImage(ciImage: outImage)
        _ = UIGraphicsBeginImageContext(finalImage.size)
        finalImage.draw(in: CGRect(x: 0, y: 0, width: finalImage.size.width, height: finalImage.size.height))
        guard let middleImage = self.icon else { return finalImage }
        let middleImageX = ((finalImage.size.width) - 65)/2.0
        middleImage.draw(in: CGRect(x: middleImageX, y: middleImageX, width: 65, height: 65))
        finalImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return finalImage
    }
}
