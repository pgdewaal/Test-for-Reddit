//
//  RedditRequests.swift
//  Test for Reddit
//
//  Created by Paul Dewaal on 6/24/17.
//  Copyright © 2017 Paul Dewaal. All rights reserved.
//

import Foundation

enum RedditEndpoint : String {
    case Top = "top"
}

class RedditRequestCreater : NSObject {
    class func getAuthorizationRequest(code:String) -> URLRequest {
        var request = URLRequest.init(url: URL.init(string: "https://www.reddit.com/api/v1/access_token")!)
        request.addValue(self.getUserAgent(), forHTTPHeaderField: "User-Agent")
        request.httpMethod = "POST"
        
        let base = String.init(format: "\(DataManager.shared.clientid):")
        let data = (base).data(using: String.Encoding.utf8)
        let base64 = data!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))

        request.addValue("Basic \(base64): ", forHTTPHeaderField: "Authorization")
        
        let body = [
            "grant_type" : "authorization_code",
            "code" : code,
            "redirect_uri" : DataManager.shared.redirectUrl
        ]
        request.httpBody = self.dictionaryToQueryString(dict: body).data(using: String.Encoding.utf8)
        return request
    }
    
    
    class func dictionaryToQueryString(dict:Dictionary<String, String>) -> String {
        var ret = ""
        
        for key in dict.keys {
            if ret != "" {
                ret.append("&")
            }
            let value = dict[key] ?? ""
            ret.append("\(key)=\(value)")
        }
        return ret
    }
    
    class func getUserAgent() -> String {
        let bundleID = Bundle.main.bundleIdentifier!
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "unknown"
        let user = "pgdewaal"
        
        return String(format:"iPhone:\(bundleID):v\(version) (by /u/\(user)")
    }
}


//class RedditRequest : NSURLRequest {
//    
//    required init(url: URL) {
////        super.init(url: url)
//        
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
//    
//    //client ID 6swhF9VsKjCyEQ
//    
//
//    func getUserAgent() -> String {
//        
//        let bundleID = Bundle.main.bundleIdentifier!
//        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "unknown"
//        let user = "pgdewaal"
//        
//        return String(format:"iPhone:\(bundleID):v\(version) (by /u/\(user)")
//    }
//}
