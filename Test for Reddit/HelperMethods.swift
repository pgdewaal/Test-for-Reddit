//
//  HelperMethods.swift
//  Test for Reddit
//
//  Created by Paul Dewaal on 6/26/17.
//  Copyright © 2017 Paul Dewaal. All rights reserved.
//

import Foundation

class Helper : NSObject {
    class func checkNull(_ object:Any?) -> Any? {
        if object is NSNull {
            return nil
        }
        else {
            return object
        }
    }
}
