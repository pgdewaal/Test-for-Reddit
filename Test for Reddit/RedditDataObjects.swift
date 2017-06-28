//
//  RedditDataObjects.swift
//  Test for Reddit
//
//  Created by Paul Dewaal on 6/25/17.
//  Copyright © 2017 Paul Dewaal. All rights reserved.
//

import Foundation
import UIKit

class RedditListing : NSObject {
    var items : Array<RedditLink>
    
    
    init(children: Array<Dictionary<String, Any>>) {
        items = Array.init()
        
        for tmp in children {
            if Helper.checkNull(tmp["data"]) != nil {
                items.append(RedditLink.init(dictionary: tmp["data"] as! Dictionary<String, Any>))
            }
        }
        super.init()
    }
}

class RedditLink : NSObject {
    var title : String
    var author : String
    var entryDate : Date?
    var commentsCount : Int
    var hasFullImage : Bool
    
    private var thumbURL : String
    private var fullURL : String
    private var thumb : UIImage?
    private var full : UIImage?
    

    init(dictionary: Dictionary<String, Any>) {
        author = Helper.checkNull(dictionary["author"]) as? String ?? ""
        commentsCount = Helper.checkNull(dictionary["num_comments"]) as? Int ?? 0
        title = Helper.checkNull(dictionary["title"]) as? String ?? ""
        thumbURL = Helper.checkNull(dictionary["thumbnail"]) as? String ?? ""
        fullURL = Helper.checkNull(dictionary["url"]) as? String ?? ""
        
        let hint = Helper.checkNull(dictionary["post_hint"]) as? String ?? ""
        hasFullImage = hint == "image"

        let since = Helper.checkNull(dictionary["created_utc"]) as? Int ?? 0
        if since != 0 {
            entryDate = Date.init(timeIntervalSince1970: TimeInterval(since))
        }
        super.init()
    }
    
    func thumbnail(completion: @escaping (_ image: UIImage?) -> ()) {
        if thumb == nil {
            if let tmpURL = URL.init(string: thumbURL)  {
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: tmpURL)
                    DispatchQueue.main.async {
                        if data != nil {
                            self.thumb = UIImage(data: data!)
                        }
                        completion(self.thumb)
                    }
                }
            }
        }
        else {
            completion(thumb)
        }
    }
    
    func fullsize(completion: @escaping (_ image: UIImage?) -> ()) {
        if full == nil {
            if let tmpURL = URL.init(string: fullURL)  {
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: tmpURL)
                    DispatchQueue.main.async {
                        if data != nil {
                            self.full = UIImage(data: data!)
                        }
                        completion(self.full)
                    }
                }
            }
        }
        else {
            completion(full)
        }
    }
}
