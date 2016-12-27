//
//  CGSize+Swift.swift
//  Haneke
//
//  Created by Oriol Blanc Gimeno on 09/09/14.
//  Copyright (c) 2014 Haneke. All rights reserved.
//

import UIKit

extension CGSize {

<<<<<<< HEAD
    func hnk_aspectFillSize(_ size: CGSize) -> CGSize {
=======
    func hnk_aspectFillSize(size: CGSize) -> CGSize {
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        let scaleWidth = size.width / self.width
        let scaleHeight = size.height / self.height
        let scale = max(scaleWidth, scaleHeight)

<<<<<<< HEAD
        let resultSize = CGSize(width: self.width * scale, height: self.height * scale)
        return CGSize(width: ceil(resultSize.width), height: ceil(resultSize.height))
    }

    func hnk_aspectFitSize(_ size: CGSize) -> CGSize {
=======
        let resultSize = CGSizeMake(self.width * scale, self.height * scale)
        return CGSizeMake(ceil(resultSize.width), ceil(resultSize.height))
    }

    func hnk_aspectFitSize(size: CGSize) -> CGSize {
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        let targetAspect = size.width / size.height
        let sourceAspect = self.width / self.height
        var resultSize = size

        if (targetAspect > sourceAspect) {
            resultSize.width = size.height * sourceAspect
        }
        else {
            resultSize.height = size.width / sourceAspect
        }
<<<<<<< HEAD
        return CGSize(width: ceil(resultSize.width), height: ceil(resultSize.height))
    }
}
=======
        return CGSizeMake(ceil(resultSize.width), ceil(resultSize.height))
    }
}
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
