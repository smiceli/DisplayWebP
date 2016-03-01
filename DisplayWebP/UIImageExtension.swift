//
//  UIImageExtension.swift
//  DisplayWebP
//
//  Created by Sean Miceli on 2/21/16.
//  Copyright © 2016 smiceli. All rights reserved.
//

import UIKit

private func freeImageData(info: UnsafeMutablePointer<Void>, data: UnsafePointer<Void>, size: Int) {
    free(UnsafeMutablePointer<Void>(data))
}

extension UIImage {
    class func imageFromWebPData(imagData: NSData) -> UIImage? {
        var width: Int32 = 0
        var height: Int32 = 0

        if WebPGetInfo(UnsafePointer<UInt8>(imagData.bytes), imagData.length, &width, &height) == 0 {
            return nil
        }
        let data = WebPDecodeRGBA(UnsafePointer<UInt8>(imagData.bytes), imagData.length, &width, &height)

        let provider = CGDataProviderCreateWithData(nil, UnsafePointer<Void>(data), Int(width * height) * 4, freeImageData)
        let colorSpaceRef = CGColorSpaceCreateDeviceRGB()

        let bi = CGBitmapInfo(rawValue: CGBitmapInfo.ByteOrderDefault.rawValue | CGImageAlphaInfo.Last.rawValue)

        let imageRef = CGImageCreate(Int(width), Int(height), 8, 32, 4 * Int(width), colorSpaceRef, bi, provider, nil, true, .RenderingIntentDefault)
        if imageRef == nil {
            return nil
        }
        return UIImage(CGImage: imageRef!)
    }
}
