//
//  UIImage+Extensions.swift
//
//  Created by Krunoslav Zaher on 11/1/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import UIKit

extension UIImage {
    func forceLazyImageDecompression() -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        draw(at: CGPoint.zero)
        UIGraphicsEndImageContext()
        return self
    }
}

