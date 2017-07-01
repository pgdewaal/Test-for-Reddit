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
    private(set) var items : Array<RedditLink> = Array.init()
    
    func addItems(data: Dictionary<String, Any>) {
        let before = Helper.checkNull(data["before"]) as? String ?? ""
        let after = Helper.checkNull(data["after"]) as? String ?? ""
        
        print("before \(before) | after \(after)")
        
        if let children = data["children"] as? Array<Dictionary<String, Any>> {
            for tmp in children {
                if let item = Helper.checkNull(tmp["data"]) as? Dictionary<String, Any> {
                    addItem(RedditLink.init(dictionary: item))
                }
            }
        }
        print("have \(items.count) items")
    }
    
    private func addItem(_ item: RedditLink) {
        let duplicate = items.index(where: { (existing) -> Bool in
            return existing.id == item.id
        })
        if let dup = duplicate {
            print("Found duplicate at \(dup)")
            print("\(item.title) = \(items[dup])")
            items.remove(at: dup)
            items.insert(item, at: dup)
        }
        else {
            items.append(item)
        }
    }
}

extension URL {
    static func httpSafeInit(string: String) -> URL? {
        return URL.init(string: string.replacingOccurrences(of: "http:", with: "https:"))
    }
}

class RedditLink : NSObject {
    private(set) var title : String
    private(set) var author : String
    private(set) var entryDate : Date?
    private(set) var commentsCount : Int
    private(set) var hasFullImage : Bool
    private(set) var id : String
    private(set) var fullname : String
    
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
        id = Helper.checkNull(dictionary["id"]) as? String ?? ""
        let hint = Helper.checkNull(dictionary["post_hint"]) as? String ?? ""
        hasFullImage = hint == "image"

        let since = Helper.checkNull(dictionary["created_utc"]) as? Int ?? 0
        if since != 0 {
            entryDate = Date.init(timeIntervalSince1970: TimeInterval(since))
        }
        fullname = Helper.checkNull(dictionary["name"]) as? String ?? ""

        super.init()
    }
    
    func thumbnail(completion: @escaping (_ image: UIImage?) -> ()) {
        if thumb == nil {
            if let tmpURL = URL.httpSafeInit(string: thumbURL)  {
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
            if let tmpURL = URL.httpSafeInit(string: fullURL)  {
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
