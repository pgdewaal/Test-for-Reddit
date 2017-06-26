//
//  RedditDataObjects.swift
//  Test for Reddit
//
//  Created by Paul Dewaal on 6/25/17.
//  Copyright © 2017 Paul Dewaal. All rights reserved.
//

import Foundation

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
    var thumb : String
    var commentsCount : Int
    
    init(dictionary: Dictionary<String, Any>) {
        author = Helper.checkNull(dictionary["author"]) as? String ?? ""
        
        
        commentsCount = Helper.checkNull(dictionary["num_comments"]) as? Int ?? 0
        title = Helper.checkNull(dictionary["title"]) as? String ?? ""
        thumb = ""
        let since = Helper.checkNull(dictionary["created_utc"]) as? Int ?? 0
        if since != 0 {
            entryDate = Date.init(timeIntervalSince1970: TimeInterval(since))
        }
    }
    
    
}
