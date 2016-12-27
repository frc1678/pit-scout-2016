//
//  Format.swift
//  Haneke
//
//  Created by Hermes Pique on 8/27/14.
//  Copyright (c) 2014 Haneke. All rights reserved.
//

import UIKit

public struct Format<T> {
    
    public let name: String
    
    public let diskCapacity : UInt64
    
    public var transform : ((T) -> (T))?
    
<<<<<<< HEAD
    public var convertToData : ((T) -> Data)?
=======
    public var convertToData : (T -> NSData)?
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f

    public init(name: String, diskCapacity : UInt64 = UINT64_MAX, transform: ((T) -> (T))? = nil) {
        self.name = name
        self.diskCapacity = diskCapacity
        self.transform = transform
    }
    
<<<<<<< HEAD
    public func apply(_ value : T) -> T {
=======
    public func apply(value : T) -> T {
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        var transformed = value
        if let transform = self.transform {
            transformed = transform(value)
        }
        return transformed
    }
    
    var isIdentity : Bool {
        return self.transform == nil
    }

}

public struct ImageResizer {
    
    public enum ScaleMode: String {
        case Fill = "fill", AspectFit = "aspectfit", AspectFill = "aspectfill", None = "none"
    }
    
    public typealias T = UIImage
    
    public let allowUpscaling : Bool
    
    public let size : CGSize
    
    public let scaleMode: ScaleMode
    
    public let compressionQuality : Float
    
<<<<<<< HEAD
    public init(size: CGSize = CGSize.zero, scaleMode: ScaleMode = .None, allowUpscaling: Bool = true, compressionQuality: Float = 1.0) {
=======
    public init(size: CGSize = CGSizeZero, scaleMode: ScaleMode = .None, allowUpscaling: Bool = true, compressionQuality: Float = 1.0) {
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        self.size = size
        self.scaleMode = scaleMode
        self.allowUpscaling = allowUpscaling
        self.compressionQuality = compressionQuality
    }
    
<<<<<<< HEAD
    public func resizeImage(_ image: UIImage) -> UIImage {
=======
    public func resizeImage(image: UIImage) -> UIImage {
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        var resizeToSize: CGSize
        switch self.scaleMode {
        case .Fill:
            resizeToSize = self.size
        case .AspectFit:
            resizeToSize = image.size.hnk_aspectFitSize(self.size)
        case .AspectFill:
            resizeToSize = image.size.hnk_aspectFillSize(self.size)
        case .None:
            return image
        }
        assert(self.size.width > 0 && self.size.height > 0, "Expected non-zero size. Use ScaleMode.None to avoid resizing.")
        
        // If does not allow to scale up the image
        if (!self.allowUpscaling) {
            if (resizeToSize.width > image.size.width || resizeToSize.height > image.size.height) {
                return image
            }
        }
        
        // Avoid unnecessary computations
        if (resizeToSize.width == image.size.width && resizeToSize.height == image.size.height) {
            return image
        }
        
<<<<<<< HEAD
        let resizedImage = image.hnk_imageByScaling(toSize: resizeToSize)
=======
        let resizedImage = image.hnk_imageByScalingToSize(resizeToSize)
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        return resizedImage
    }
}
