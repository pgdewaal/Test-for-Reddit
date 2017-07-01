//
//  RedditRequestBase.swift
//  Test for Reddit
//
//  Created by Paul Dewaal on 6/28/17.
//  Copyright © 2017 Paul Dewaal. All rights reserved.
//

import Foundation


enum RedditEndpoint : String {
    case Top = "top"
    case Authorization = "api/v1/access_token"
}

class RedditRequestBase : NSObject {
    var endpoint : RedditEndpoint
    var httpMethod : String
    var requiresAuth : Bool
    var bodyParameters : Dictionary<String, String>?
    var urlParameters : Dictionary<String, String>?
    var headers : Dictionary<String, String>?
    
    private var baseURL : String
    
    
    init(endpoint: RedditEndpoint, httpMethod: String, requiresAuth: Bool) {
        self.endpoint = endpoint
        self.httpMethod = httpMethod
        self.requiresAuth = requiresAuth
        baseURL = requiresAuth ? "https://oauth.reddit.com/" : "https://www.reddit.com/"
        super.init()
    }
    
    func createRequest() -> URLRequest {
        if let URL = URL.init(string:buildURLString()) {
            var request = URLRequest.init(url: URL)
            request.httpMethod = httpMethod
            if let body = bodyParameters {
                request.httpBody = dictionaryToQueryString(dict: body).data(using: String.Encoding.utf8)
            }
            
            request.addValue(getUserAgent(), forHTTPHeaderField: "User-Agent")
            if let tmp = headers {
                for key in tmp.keys {
                    request.addValue(tmp[key]!, forHTTPHeaderField: key)
                }
            }
            
            if requiresAuth {
                if let token = DataManager.shared.accessToken {
                    request.addValue("bearer \(token)", forHTTPHeaderField: "Authorization")
                }
                else {
                    fatalError("Access Token is nil. Please check if '\(URL.absoluteString)' actually requires the token or you are making this call before retrieving the token")
                }
            }
            
            return request
        }
        else {
            fatalError("Request unable to be created because of bad URL String \n\(buildURLString())")
        }
    }
    
    private func buildURLString() -> String {
        var url = String.init("\(baseURL)\(endpoint.rawValue)")
        if let parameters = urlParameters {
            url?.append("?\(dictionaryToQueryString(dict: parameters))")
        }
        return url ?? ""
    }
    
    private func dictionaryToQueryString(dict:Dictionary<String, String>) -> String {
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
    
    private func getUserAgent() -> String {
        let bundleID = Bundle.main.bundleIdentifier!
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "unknown"
        let user = "pgdewaal"
        return String(format:"iPhone:\(bundleID):v\(version) (by /u/\(user))")
    }
}
