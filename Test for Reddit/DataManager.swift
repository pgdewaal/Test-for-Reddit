//
//  DataManager.swift
//  Test for Reddit
//
//  Created by Paul Dewaal on 6/24/17.
//  Copyright © 2017 Paul Dewaal. All rights reserved.
//

import Foundation

class DataManager : NSObject {
    
    static let shared = DataManager()
    
    var userCode : String?
    var accessToken : String?
    var state : String
    var top : RedditListing
    

    private(set) var clientid : String {
        get {
            let path = Bundle.main.path(forResource: "Info", ofType: "plist")
            let dict = NSDictionary(contentsOfFile: path!)
            if (dict?["clientid"] != nil) {
                return dict!.value(forKey: "clientid") as! String
            }
            else {
                return ""
            }
        }
        set {}
    }
    
    private(set) var redirectUrl : String {
        get {
            let path = Bundle.main.path(forResource: "Info", ofType: "plist")
            let dict = NSDictionary(contentsOfFile: path!)
            if (dict?["redirect"] != nil) {
                return dict!.value(forKey: "redirect") as! String
            }
            else {
                return ""
            }
        }
        set {}
    }
    
    
    override init() {
        state = UUID.init().uuidString
        top = RedditListing.init()
        super.init()
    }
    
    func redirectUrlEncoded() -> String {
        return self.redirectUrl.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    
}
