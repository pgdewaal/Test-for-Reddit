//
//  RedditRequests.swift
//  Test for Reddit
//
//  Created by Paul Dewaal on 6/24/17.
//  Copyright © 2017 Paul Dewaal. All rights reserved.
//

import Foundation


class RedditRequestCreater : NSObject {
    
    class func makeAuthorizationRequest(completion: @escaping (_ success: Bool) -> ()) {
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
        
        session.dataTask(with: request) { (data, response, error) in
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
            
            }.resume()
    }
    
    class func makeTop50Request(completion: @escaping (_ success: Bool) -> ()) {
        let top = RedditRequestBase.init(endpoint: RedditEndpoint.Top, httpMethod: "GET", requiresAuth: true)
        let after = DataManager.shared.top.items.last?.fullname
        top.urlParameters = [
            "t" : "day",
            "limit" : "50",
            "count" : String(DataManager.shared.top.items.count),
            "after" : after ?? ""
        ]

        let session = URLSession.init(configuration: URLSessionConfiguration.default)
        let request = top.createRequest()
        session.dataTask(with: request) { (data, response, error) in
            print("Response top 50 recieved!")
            do {
                //So I would normally handle the case of hitting the "end" of a listing, but I'm only doing happy path for the test
                if let data = data {
                    let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [String : Any]
                    if let dict = Helper.checkNull(json["data"]) as? [String : Any] {
                        DataManager.shared.top.addItems(data: dict)
                    }
                    DispatchQueue.main.async {
                        completion(true)
                    }
                }
                else {
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
                
            }
            catch {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    completion(false)
                }
            }
            
        }.resume()
    }
}
