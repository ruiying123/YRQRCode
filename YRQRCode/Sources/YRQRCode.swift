//
//  YRQRCode.swift
//  YRQRCode
//
//  Created by kilrae on 2017/4/17.
//  Copyright © 2017年 yang. All rights reserved.
//

import UIKit

class YRQRCode: NSObject {
    public static func recognize(image: CGImage) -> [String]? {
        return YRQRCodeRecognizer(image: image).contents
    }
    
    public static func generator(content: String?, size: CGFloat?, icon: UIImage?) -> UIImage? {
        let generator = YRQRCodeGenerator(content: content, size: size, icon: icon)
        return generator.image
    }
}
