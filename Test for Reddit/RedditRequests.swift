//
//  RedditRequests.swift
//  Test for Reddit
//
//  Created by Paul Dewaal on 6/24/17.
//  Copyright © 2017 Paul Dewaal. All rights reserved.
//

import Foundation


class RedditRequestCreater : NSObject {
    
    static let shared = RedditRequestCreater()

    var task : URLSessionDataTask?
    var requestDelay : Double?
    
    func makeAuthorizationRequest(completion: @escaping (_ success: Bool) -> ()) {
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
        runRequest(auth.createRequest()) { (data, response, error) in
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
                DispatchQueue.main.async {
                    completion(false)
                }
            }
            
        }
    }
    
    // MARK: - Public Request Creater Methods
    
    func makeTop50Request(listing: RedditListing, after: String?, before: String?, completion: @escaping (_ success: Bool) -> ()) {
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

        runRequest(top.createRequest()) { (data, response, error) in
            self.updateRates(withResponse: response)
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
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
    
    func refreshTop50Request(listing: RedditListing, completion: @escaping (_ success: Bool) -> ()) {
        let top = RedditRequestBase.init(endpoint: RedditEndpoint.Top, httpMethod: "GET", requiresAuth: true)
        top.urlParameters = [
            "t" : "day",
            "limit" : "50",
            "count" : "0",
            "after" : ""
        ]
        
        runRequest(top.createRequest()) { (data, response, error) in
            if let data = data {
                listing.deleteFromCD()
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
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
    
    func getUser(completion: @escaping (_ success: Bool) -> ()) {
        let user = RedditRequestBase.init(endpoint: RedditEndpoint.User, httpMethod: "GET", requiresAuth: true)
        
        runRequest(user.createRequest()) { (data, response, error) in
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
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
    
    func signout() {
        guard let token = DataManager.shared.accessToken else {
            return
        }
        
        let signout = RedditRequestBase.init(endpoint: RedditEndpoint.Logout, httpMethod: "POST", requiresAuth: false)
        signout.bodyParameters = [
            "token" : token,
            "token_type_hint" : "access_token"
        ]
        runRequest(signout.createRequest()) { (data, response, error) in
            
        }
    }
    
    // MARK: - Helper Methods
    
    private func checkRates() {
        if let delay = requestDelay {
            DispatchQueue.global().asyncAfter(deadline: .now() + delay, execute: {
                self.task?.resume()
            })
        }
        else {
            task?.resume()
        }
    }
    
    private func runRequest(_ request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void){
        task?.cancel()
        let session = URLSession.init(configuration: URLSessionConfiguration.default)
        task = session.dataTask(with: request) { (data, response, error) in
            if error?.localizedDescription == "cancelled" {
                return
            }
            self.updateRates(withResponse: response)
            completionHandler(data, response, error)
        }
        checkRates()
    }
    
    private func updateRates(withResponse response: URLResponse?) {
        if let response = response as? HTTPURLResponse {
            guard let used = response.allHeaderFields["x-ratelimit-used"] as? String else {
                return
            }
            guard let remaining = response.allHeaderFields["x-ratelimit-remaining"] as? String else {
                return
            }
            guard let reset = response.allHeaderFields["x-ratelimit-reset"] as? String else {
                return
            }
           
            if Double(remaining)! <= 1 || Int(used)! >= 60 {
                requestDelay = Double(reset)!
            }
        }
    }
}
