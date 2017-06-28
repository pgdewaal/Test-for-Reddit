//
//  HelperMethods.swift
//  Test for Reddit
//
//  Created by Paul Dewaal on 6/26/17.
//  Copyright © 2017 Paul Dewaal. All rights reserved.
//

import UIKit

class Helper : NSObject {
    
    class func checkNull(_ object:Any?) -> Any? {
        if object is NSNull {
            return nil
        }
        else {
            return object
        }
    }
    
    class func hoursFromNow(withDate: Date?) -> Int {
        let interval = Date().timeIntervalSince(withDate ?? Date())
        if interval == 0 {
            return 0
        }
        else {
            return Int(interval/60.0/60.0)
        }
    }
}
