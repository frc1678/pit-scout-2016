//
//  NSHTTPURLResponse+Haneke.swift
//  Haneke
//
<<<<<<< HEAD
//  Created by Hermes Pique on 1/2/16.
//  Copyright © 2016 Haneke. All rights reserved.
=======
//  Created by Hermes Pique on 9/12/14.
//  Copyright (c) 2014 Haneke. All rights reserved.
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
//

import Foundation

<<<<<<< HEAD
extension HTTPURLResponse {

    func hnk_isValidStatusCode() -> Bool {
        switch self.statusCode {
        case 200...201:
            return true
        default:
            return false
        }
    }

}
=======
extension NSHTTPURLResponse {
    
    func hnk_validateLengthOfData(data: NSData) -> Bool {
        let expectedContentLength = self.expectedContentLength
        if (expectedContentLength > -1) {
            let dataLength = data.length
            return Int64(dataLength) >= expectedContentLength
        }
        return true
    }
    
}
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
