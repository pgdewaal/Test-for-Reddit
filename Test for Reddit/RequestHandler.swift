//
//  RequestHandler.swift
//  Test for Reddit
//
//  Created by Paul Dewaal on 6/24/17.
//  Copyright © 2017 Paul Dewaal. All rights reserved.
//

import Foundation

enum RequestType : String {
    case POST = "POST"
    case GET = "GET"
    case PUT = "PUT"
    case DELETE = "DELETE"
}


class RequestHandler : NSObject {
    
    var endpoint : String
    var base : String
    var method : RequestType
//    var request : NSURLSession
//    var task = NSURLSessionDataTask
    
    override init() {
        endpoint = ""
        base = ""
        method = RequestType.POST
        super.init()
    }
    
    func submitCallWithResponse() -> (response: Dictionary<String, Any>?, error: Error?) {
        let url = String(format: "\(base)/\(endpoint)" as String);
        //        NSURL url = NSURL.init(string: <#T##String#>)
        //        task = request.dataTaskWithURL:(url: NSURL.init(string: url) completionHandler:)
        return (nil, nil);
    }
}
