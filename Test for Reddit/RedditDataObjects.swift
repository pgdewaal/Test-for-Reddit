//
//  RedditDataObjects.swift
//  Test for Reddit
//
//  Created by Paul Dewaal on 6/25/17.
//  Copyright © 2017 Paul Dewaal. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class RedditListing : NSObject {
    private(set) var items : Array<RedditLink> = Array.init()
    
    override init() {
        super.init()
    }
    
    func addItems(data: Dictionary<String, Any>) {
        let before = Helper.checkNull(data["before"]) as? String ?? ""
        let after = Helper.checkNull(data["after"]) as? String ?? ""
        
        
        print("before \(before) | after \(after)")
        
        if let children = data["children"] as? Array<Dictionary<String, Any>> {
            var count = 0
            for tmp in children {
                if var item = Helper.checkNull(tmp["data"]) as? Dictionary<String, Any> {
                    item.updateValue(count, forKey: "orderCount")
                    count += 1
                    if let descript = NSEntityDescription.entity(forEntityName: "Link", in: Helper.getContext()) {
                        let link = RedditLink.init(entity: descript, insertInto: Helper.getContext(), withDictionary: item)
                        addItem(link)
                    }
                    else {
                        print("Error creating description")
                    }
                }
            }
        }
        print("have \(items.count) items")
        saveToCD()
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
    
    func saveToCD() {
        do {
            try Helper.getContext().save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    func deleteFromCD() {
        let context = Helper.getContext()
        for item in items {
            context.delete(item)
        }
        items.removeAll()
        saveToCD()
    }
    
    func retrieveItemsForUser(_ user: String){
        do {
            let fetch = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Link")
            fetch.predicate = NSPredicate.init(format: "user == %@", user)
            fetch.sortDescriptors = [NSSortDescriptor.init(key: "order", ascending: true)]
            
            if let links = try Helper.getContext().fetch(fetch) as? [RedditLink] {
                items = links
                print("Found these \(links.count) links")
            }
            else {
                print("Found no links")
            }
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }
    }
}

extension URL {
    static func httpSafeInit(string: String) -> URL? {
        return URL.init(string: string.replacingOccurrences(of: "http:", with: "https:"))
    }
}

class RedditLink : NSManagedObject {
    @NSManaged private(set) var title : String
    @NSManaged private(set) var author : String
    @NSManaged private(set) var entryDate : Date?
    @NSManaged private(set) var commentsCount : Int
    @NSManaged private(set) var hasFullImage : Bool
    @NSManaged private(set) var id : String
    @NSManaged private(set) var fullname : String
    @NSManaged private(set) var order : Int
    @NSManaged private(set) var user : String

    @NSManaged private var thumbURL : String
    @NSManaged private var fullURL : String
    private var thumb : UIImage?
    private var full : UIImage?
    
    class func entityDescription() -> String {
        return "Link"
    }
    
    init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?, withDictionary dictionary: Dictionary<String, Any>) {
        super.init(entity: entity, insertInto: context)
        order = dictionary["orderCount"] as! Int
        user = DataManager.shared.user ?? "<Unknown/Failed>"
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
    }
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
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
