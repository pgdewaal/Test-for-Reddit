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
    
    var authToken : String
    var state : String

    var clientid : String {
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
    var redirectUrl : String {
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
        authToken = ""
        state = UUID.init().uuidString
        print("state is \(state)")
        super.init()
    }
    
    func redirectUrlEncoded() -> String {
        return self.redirectUrl.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    func getToken(code: String) {
        let session = URLSession.init(configuration: URLSessionConfiguration.default)
        let request = RedditRequestCreater.getAuthorizationRequest(code: code)
        
        print("Running the request!")
        
        let task = session.dataTask(with: request) { (data, response, error) in
            print("Response recieved!")
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                print("RESPONSE IS \(json)")
            }
            catch {
                print(error.localizedDescription)
            }
            
        }
        task.resume()
    }

}
