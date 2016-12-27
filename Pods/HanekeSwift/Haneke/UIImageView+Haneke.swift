//
//  UIImageView+Haneke.swift
//  Haneke
//
//  Created by Hermes Pique on 9/17/14.
//  Copyright (c) 2014 Haneke. All rights reserved.
//

import UIKit

public extension UIImageView {
    
    public var hnk_format : Format<UIImage> {
        let viewSize = self.bounds.size
<<<<<<< HEAD
            assert(viewSize.width > 0 && viewSize.height > 0, "[\(Mirror(reflecting: self).description) \(#function)]: UImageView size is zero. Set its frame, call sizeToFit or force layout first.")
=======
            assert(viewSize.width > 0 && viewSize.height > 0, "[\(Mirror(reflecting: self).description) \(__FUNCTION__)]: UImageView size is zero. Set its frame, call sizeToFit or force layout first.")
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
            let scaleMode = self.hnk_scaleMode
            return HanekeGlobals.UIKit.formatWithSize(viewSize, scaleMode: scaleMode)
    }
    
<<<<<<< HEAD
    public func hnk_setImageFromURL(_ URL: Foundation.URL, placeholder : UIImage? = nil, format : Format<UIImage>? = nil, failure fail : ((Error?) -> ())? = nil, success succeed : ((UIImage) -> ())? = nil) {
        let fetcher = NetworkFetcher<UIImage>(URL: URL)
        self.hnk_setImage(fromFetcher: fetcher, placeholder: placeholder, format: format, failure: fail, success: succeed)
    }
    
    public func hnk_setImage( _ image: @autoclosure @escaping () -> UIImage, key: String, placeholder : UIImage? = nil, format : Format<UIImage>? = nil, success succeed : ((UIImage) -> ())? = nil) {
        let fetcher = SimpleFetcher<UIImage>(key: key, value: image)
        self.hnk_setImage(fromFetcher: fetcher, placeholder: placeholder, format: format, success: succeed)
    }
    
    public func hnk_setImageFromFile(_ path: String, placeholder : UIImage? = nil, format : Format<UIImage>? = nil, failure fail : ((Error?) -> ())? = nil, success succeed : ((UIImage) -> ())? = nil) {
        let fetcher = DiskFetcher<UIImage>(path: path)
        self.hnk_setImage(fromFetcher: fetcher, placeholder: placeholder, format: format, failure: fail, success: succeed)
    }
    
    public func hnk_setImage(fromFetcher fetcher : Fetcher<UIImage>,
        placeholder : UIImage? = nil,
        format : Format<UIImage>? = nil,
        failure fail : ((Error?) -> ())? = nil,
=======
    public func hnk_setImageFromURL(URL: NSURL, placeholder : UIImage? = nil, format : Format<UIImage>? = nil, failure fail : ((NSError?) -> ())? = nil, success succeed : ((UIImage) -> ())? = nil) {
        let fetcher = NetworkFetcher<UIImage>(URL: URL)
        self.hnk_setImageFromFetcher(fetcher, placeholder: placeholder, format: format, failure: fail, success: succeed)
    }
    
    public func hnk_setImage(@autoclosure(escaping) image: () -> UIImage, key: String, placeholder : UIImage? = nil, format : Format<UIImage>? = nil, success succeed : ((UIImage) -> ())? = nil) {
        let fetcher = SimpleFetcher<UIImage>(key: key, value: image)
        self.hnk_setImageFromFetcher(fetcher, placeholder: placeholder, format: format, success: succeed)
    }
    
    public func hnk_setImageFromFile(path: String, placeholder : UIImage? = nil, format : Format<UIImage>? = nil, failure fail : ((NSError?) -> ())? = nil, success succeed : ((UIImage) -> ())? = nil) {
        let fetcher = DiskFetcher<UIImage>(path: path)
        self.hnk_setImageFromFetcher(fetcher, placeholder: placeholder, format: format, failure: fail, success: succeed)
    }
    
    public func hnk_setImageFromFetcher(fetcher : Fetcher<UIImage>,
        placeholder : UIImage? = nil,
        format : Format<UIImage>? = nil,
        failure fail : ((NSError?) -> ())? = nil,
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        success succeed : ((UIImage) -> ())? = nil) {

        self.hnk_cancelSetImage()
        
        self.hnk_fetcher = fetcher
        
        let didSetImage = self.hnk_fetchImageForFetcher(fetcher, format: format, failure: fail, success: succeed)
        
        if didSetImage { return }
     
        if let placeholder = placeholder {
            self.image = placeholder
        }
    }
    
    public func hnk_cancelSetImage() {
        if let fetcher = self.hnk_fetcher {
            fetcher.cancelFetch()
            self.hnk_fetcher = nil
        }
    }
    
    // MARK: Internal
    
    // See: http://stackoverflow.com/questions/25907421/associating-swift-things-with-nsobject-instances
    var hnk_fetcher : Fetcher<UIImage>! {
        get {
            let wrapper = objc_getAssociatedObject(self, &HanekeGlobals.UIKit.SetImageFetcherKey) as? ObjectWrapper
<<<<<<< HEAD
            let fetcher = wrapper?.hnk_value as? Fetcher<UIImage>
=======
            let fetcher = wrapper?.value as? Fetcher<UIImage>
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
            return fetcher
        }
        set (fetcher) {
            var wrapper : ObjectWrapper?
            if let fetcher = fetcher {
                wrapper = ObjectWrapper(value: fetcher)
            }
            objc_setAssociatedObject(self, &HanekeGlobals.UIKit.SetImageFetcherKey, wrapper, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var hnk_scaleMode : ImageResizer.ScaleMode {
        switch (self.contentMode) {
<<<<<<< HEAD
        case .scaleToFill:
            return .Fill
        case .scaleAspectFit:
            return .AspectFit
        case .scaleAspectFill:
            return .AspectFill
        case .redraw, .center, .top, .bottom, .left, .right, .topLeft, .topRight, .bottomLeft, .bottomRight:
=======
        case .ScaleToFill:
            return .Fill
        case .ScaleAspectFit:
            return .AspectFit
        case .ScaleAspectFill:
            return .AspectFill
        case .Redraw, .Center, .Top, .Bottom, .Left, .Right, .TopLeft, .TopRight, .BottomLeft, .BottomRight:
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
            return .None
            }
    }

<<<<<<< HEAD
    func hnk_fetchImageForFetcher(_ fetcher : Fetcher<UIImage>, format : Format<UIImage>? = nil, failure fail : ((Error?) -> ())?, success succeed : ((UIImage) -> ())?) -> Bool {
=======
    func hnk_fetchImageForFetcher(fetcher : Fetcher<UIImage>, format : Format<UIImage>? = nil, failure fail : ((NSError?) -> ())?, success succeed : ((UIImage) -> ())?) -> Bool {
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        let cache = Shared.imageCache
        let format = format ?? self.hnk_format
        if cache.formats[format.name] == nil {
            cache.addFormat(format)
        }
        var animated = false
        let fetch = cache.fetch(fetcher: fetcher, formatName: format.name, failure: {[weak self] error in
            if let strongSelf = self {
<<<<<<< HEAD
                if strongSelf.hnk_shouldCancel(forKey: fetcher.key) { return }
=======
                if strongSelf.hnk_shouldCancelForKey(fetcher.key) { return }
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
                
                strongSelf.hnk_fetcher = nil
                
                fail?(error)
            }
        }) { [weak self] image in
            if let strongSelf = self {
<<<<<<< HEAD
                if strongSelf.hnk_shouldCancel(forKey: fetcher.key) { return }
=======
                if strongSelf.hnk_shouldCancelForKey(fetcher.key) { return }
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
                
                strongSelf.hnk_setImage(image, animated: animated, success: succeed)
            }
        }
        animated = true
        return fetch.hasSucceeded
    }
    
<<<<<<< HEAD
    func hnk_setImage(_ image : UIImage, animated : Bool, success succeed : ((UIImage) -> ())?) {
=======
    func hnk_setImage(image : UIImage, animated : Bool, success succeed : ((UIImage) -> ())?) {
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        self.hnk_fetcher = nil
        
        if let succeed = succeed {
            succeed(image)
<<<<<<< HEAD
        } else if animated {
            UIView.transition(with: self, duration: HanekeGlobals.UIKit.SetImageAnimationDuration, options: .transitionCrossDissolve, animations: {
                self.image = image
            }, completion: nil)
        } else {
            self.image = image
        }
    }
    
    func hnk_shouldCancel(forKey key:String) -> Bool {
        if self.hnk_fetcher?.key == key { return false }
        
        Log.debug(message: "Cancelled set image for \((key as NSString).lastPathComponent)")
=======
        } else {
            let duration : NSTimeInterval = animated ? 0.1 : 0
            UIView.transitionWithView(self, duration: duration, options: .TransitionCrossDissolve, animations: {
                self.image = image
            }, completion: nil)
        }
    }
    
    func hnk_shouldCancelForKey(key:String) -> Bool {
        if self.hnk_fetcher?.key == key { return false }
        
        Log.debug("Cancelled set image for \((key as NSString).lastPathComponent)")
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        return true
    }
    
}
