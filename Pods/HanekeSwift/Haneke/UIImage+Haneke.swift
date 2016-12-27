//
//  UIImage+Haneke.swift
//  Haneke
//
//  Created by Hermes Pique on 8/10/14.
//  Copyright (c) 2014 Haneke. All rights reserved.
//

import UIKit

extension UIImage {

<<<<<<< HEAD
    func hnk_imageByScaling(toSize size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, !hnk_hasAlpha(), 0.0)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage!
    }

    func hnk_hasAlpha() -> Bool {
        guard let alphaInfo = self.cgImage?.alphaInfo else { return false }
        switch alphaInfo {
        case .first, .last, .premultipliedFirst, .premultipliedLast, .alphaOnly:
            return true
        case .none, .noneSkipFirst, .noneSkipLast:
=======
    func hnk_imageByScalingToSize(toSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(toSize, !hnk_hasAlpha(), 0.0)
        drawInRect(CGRectMake(0, 0, toSize.width, toSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }

    func hnk_hasAlpha() -> Bool {
        let alpha = CGImageGetAlphaInfo(self.CGImage)
        switch alpha {
        case .First, .Last, .PremultipliedFirst, .PremultipliedLast, .Only:
            return true
        case .None, .NoneSkipFirst, .NoneSkipLast:
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
            return false
        }
    }
    
<<<<<<< HEAD
    func hnk_data(compressionQuality: Float = 1.0) -> Data! {
=======
    func hnk_data(compressionQuality compressionQuality: Float = 1.0) -> NSData! {
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        let hasAlpha = self.hnk_hasAlpha()
        let data = hasAlpha ? UIImagePNGRepresentation(self) : UIImageJPEGRepresentation(self, CGFloat(compressionQuality))
        return data
    }
    
    func hnk_decompressedImage() -> UIImage! {
<<<<<<< HEAD
        let originalImageRef = self.cgImage
        let originalBitmapInfo = originalImageRef?.bitmapInfo
        guard let alphaInfo = originalImageRef?.alphaInfo else { return UIImage() }
        
        // See: http://stackoverflow.com/questions/23723564/which-cgimagealphainfo-should-we-use
        var bitmapInfo = originalBitmapInfo
        switch alphaInfo {
        case .none:
            let rawBitmapInfoWithoutAlpha = (bitmapInfo?.rawValue)! & ~CGBitmapInfo.alphaInfoMask.rawValue
            let rawBitmapInfo = rawBitmapInfoWithoutAlpha | CGImageAlphaInfo.noneSkipFirst.rawValue
            bitmapInfo = CGBitmapInfo(rawValue: rawBitmapInfo)
        case .premultipliedFirst, .premultipliedLast, .noneSkipFirst, .noneSkipLast:
            break
        case .alphaOnly, .last, .first: // Unsupported
=======
        let originalImageRef = self.CGImage
        let originalBitmapInfo = CGImageGetBitmapInfo(originalImageRef)
        let alphaInfo = CGImageGetAlphaInfo(originalImageRef)
        
        // See: http://stackoverflow.com/questions/23723564/which-cgimagealphainfo-should-we-use
        var bitmapInfo = originalBitmapInfo
        switch (alphaInfo) {
        case .None:
            let rawBitmapInfoWithoutAlpha = bitmapInfo.rawValue & ~CGBitmapInfo.AlphaInfoMask.rawValue
            let rawBitmapInfo = rawBitmapInfoWithoutAlpha | CGImageAlphaInfo.NoneSkipFirst.rawValue
            bitmapInfo = CGBitmapInfo(rawValue: rawBitmapInfo)
        case .PremultipliedFirst, .PremultipliedLast, .NoneSkipFirst, .NoneSkipLast:
            break
        case .Only, .Last, .First: // Unsupported
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
            return self
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
<<<<<<< HEAD
        let pixelSize = CGSize(width: self.size.width * self.scale, height: self.size.height * self.scale)
        guard let context = CGContext(data: nil, width: Int(ceil(pixelSize.width)), height: Int(ceil(pixelSize.height)), bitsPerComponent: (originalImageRef?.bitsPerComponent)!, bytesPerRow: 0, space: colorSpace, bitmapInfo: (bitmapInfo?.rawValue)!) else {
            return self
        }

        let imageRect = CGRect(x: 0, y: 0, width: pixelSize.width, height: pixelSize.height)
        UIGraphicsPushContext(context)
        
        // Flip coordinate system. See: http://stackoverflow.com/questions/506622/cgcontextdrawimage-draws-image-upside-down-when-passed-uiimage-cgimage
        context.translateBy(x: 0, y: pixelSize.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        // UIImage and drawInRect takes into account image orientation, unlike CGContextDrawImage.
        self.draw(in: imageRect)
        UIGraphicsPopContext()
        
        guard let decompressedImageRef = context.makeImage() else {
            return self
        }
        
        let scale = UIScreen.main.scale
        let image = UIImage(cgImage: decompressedImageRef, scale:scale, orientation:UIImageOrientation.up)
=======
        let pixelSize = CGSizeMake(self.size.width * self.scale, self.size.height * self.scale)
        guard let context = CGBitmapContextCreate(nil, Int(ceil(pixelSize.width)), Int(ceil(pixelSize.height)), CGImageGetBitsPerComponent(originalImageRef), 0, colorSpace, bitmapInfo.rawValue) else {
            return self
        }

        let imageRect = CGRectMake(0, 0, pixelSize.width, pixelSize.height)
        UIGraphicsPushContext(context)
        
        // Flip coordinate system. See: http://stackoverflow.com/questions/506622/cgcontextdrawimage-draws-image-upside-down-when-passed-uiimage-cgimage
        CGContextTranslateCTM(context, 0, pixelSize.height)
        CGContextScaleCTM(context, 1.0, -1.0)
        
        // UIImage and drawInRect takes into account image orientation, unlike CGContextDrawImage.
        self.drawInRect(imageRect)
        UIGraphicsPopContext()
        
        guard let decompressedImageRef = CGBitmapContextCreateImage(context) else {
            return self
        }
        
        let scale = UIScreen.mainScreen().scale
        let image = UIImage(CGImage: decompressedImageRef, scale:scale, orientation:UIImageOrientation.Up)
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        return image
    }

}
