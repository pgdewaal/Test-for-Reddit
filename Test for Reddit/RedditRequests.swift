//
//  RedditRequests.swift
//  Test for Reddit
//
//  Created by Paul Dewaal on 6/24/17.
//  Copyright © 2017 Paul Dewaal. All rights reserved.
//

import Foundation


class RedditRequestCreater : NSObject {
    
    static var task : URLSessionDataTask?
    
    class func makeAuthorizationRequest(completion: @escaping (_ success: Bool) -> ()) {
        task?.cancel()
        let auth = RedditRequestBase.init(endpoint: RedditEndpoint.Authorization, httpMethod: "POST", requiresAuth: false)
        
        let base = String.init(format: "\(DataManager.shared.clientid):")
        let data = (base).data(using: String.Encoding.utf8)
        let base64 = data!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))

        auth.headers = [
            "Authorization" : "Basic \(base64): "
        ]
        auth.bodyParameters = [
            "grant_type" : "authorization_code",
            "code" : DataManager.shared.userCode!,
            "redirect_uri" : DataManager.shared.redirectUrl,
            "duration" : "permanent"
        ]
        let session = URLSession.init(configuration: URLSessionConfiguration.default)
        let request = auth.createRequest()
        
        task = session.dataTask(with: request) { (data, response, error) in
            print("Response recieved!")
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [String : Any]
                    DataManager.shared.accessToken = json["access_token"] as? String
                    DispatchQueue.main.async {
                        completion(true)
                    }
                }
                catch {
                    DispatchQueue.main.async {
                        completion(false)
                    }
                    print(error.localizedDescription)
                }
            }
            else {
                if error?.localizedDescription != "cancelled" {
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            }
            
            }
        task?.resume()
    }
    
    class func makeTop50Request(listing: RedditListing, after: String?, before: String?, completion: @escaping (_ success: Bool) -> ()) {
        task?.cancel()
        
        let top = RedditRequestBase.init(endpoint: RedditEndpoint.Top, httpMethod: "GET", requiresAuth: true)
        if let before = before {
            top.urlParameters = [
                "t" : "day",
                "limit" : "49",
                "count" : String(listing.items.count),
                "before" : before
            ]
        }
        else {
            top.urlParameters = [
                "t" : "day",
                "limit" : "50",
                "count" : String(listing.items.count),
                "after" : after ?? ""
            ]
        }

        let session = URLSession.init(configuration: URLSessionConfiguration.default)
        let request = top.createRequest()
        task = session.dataTask(with: request) { (data, response, error) in
            print("Response top 50 recieved!")
            //So I would normally handle the case of hitting the "end" of a listing, but I'm only doing happy path for the test
            if let data = data {
                do {
                    
                    let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [String : Any]
                    if let dict = Helper.checkNull(json["data"]) as? [String : Any] {
                        listing.addItems(data: dict)
                    }
                    DispatchQueue.main.async {
                        completion(true)
                    }
                }
                catch {
                    print(error.localizedDescription)
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            }
            else {
                if error?.localizedDescription != "cancelled" {
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            }
        }
        task?.resume()
    }
    
    class func getUser(completion: @escaping (_ success: Bool) -> ()) {
        task?.cancel()
        
        let top = RedditRequestBase.init(endpoint: RedditEndpoint.User, httpMethod: "GET", requiresAuth: true)
        
        let session = URLSession.init(configuration: URLSessionConfiguration.default)
        let request = top.createRequest()
        task = session.dataTask(with: request) { (data, response, error) in
                //So I would normally handle the case of hitting the "end" of a listing, but I'm only doing happy path for the test
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [String : Any]
                    if let name = json["name"] as? String{
                        DataManager.shared.user = name
                    }
                    DispatchQueue.main.async {
                        completion(true)
                    }
                }
                catch {
                    print(error.localizedDescription)
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            }
            else {
                if error?.localizedDescription != "cancelled" {
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            }
        }
        task?.resume()
    }
}
