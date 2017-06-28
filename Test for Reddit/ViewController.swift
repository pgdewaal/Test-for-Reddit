//
//  ViewController.swift
//  Test for Reddit
//
//  Created by Paul Dewaal on 6/24/17.
//  Copyright © 2017 Paul Dewaal. All rights reserved.
//

import UIKit

extension URL {
    func getDictionaryOfUrlQueries() -> Dictionary<String, String> {
        let array = self.query?.components(separatedBy: "&")
        var dict = NSMutableDictionary.init()
        
        for query in array! {
            let key = query.components(separatedBy: "=").first
            let value = query.components(separatedBy: "=").last
            dict.setValue(value, forKey: key!)
        }
        
        return dict as! Dictionary<String, String>
    }
}

class ViewController: UIViewController, UIWebViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var loginView: UIWebView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var listings : RedditListing?

    override func viewDidLoad() {
        super.viewDidLoad()
        print("url: \(DataManager.shared.redirectUrl)")
        print("encoded: \(DataManager.shared.redirectUrlEncoded())");
        self.attemptLogin()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
         return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (listings != nil) ? listings!.items.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "redditCell", for: indexPath as IndexPath) as! RedditCollectionCell
        if let link = listings?.items[indexPath.row] {
            cell.updateCell(forRedditLink: link)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width*(9.0/16.0));
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let link = listings?.items[indexPath.row] {
            if link.hasFullImage {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "fullscreenImageVC") as! FullScreenImageVC
                controller.link = link
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
    
    
    func attemptLogin() {
        let login = URLRequest.init(url: URL.init(string: "https://www.reddit.com/api/v1/authorize.compact?client_id=6swhF9VsKjCyEQ&response_type=code&state=\(DataManager.shared.state)&redirect_uri=\(DataManager.shared.redirectUrlEncoded())&duration=permanent&scope=read")!)
        loginView.loadRequest(login)
    }
    
    func userInputReceived(success:Bool) {
        self.loginView.alpha = 0

        if success && DataManager.shared.userCode != nil {
            let session = URLSession.init(configuration: URLSessionConfiguration.default)
            let request = RedditRequestCreater.getAuthorizationRequest(code: DataManager.shared.userCode!)
            
            print("Running the request!")
            
            let task = session.dataTask(with: request) { (data, response, error) in
                print("Response recieved!")
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String : Any]
                    DataManager.shared.accessToken = json["access_token"] as? String
                }
                catch {
                    print(error.localizedDescription)
                }
                self.getTop50()
            }
            task.resume()
        }
        else {
            let alert = UIAlertController.init(title: "Error", message: "Only supporting the happy path, please try again", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction.init(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
                self.loginView.alpha = 1
                self.attemptLogin()
            }))
            self.present(alert, animated: true, completion: { 
                
            })
        }
    }
    
    func getTop50() {
        let session = URLSession.init(configuration: URLSessionConfiguration.default)
        let request = RedditRequestCreater.getTop50Request()
        
        print("Running the top 50 request!")
        
        let task = session.dataTask(with: request) { (data, response, error) in
            print("Response top 50 recieved!")
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String : Any]
                if Helper.checkNull(json["data"]) != nil {
                    let dict = json["data"] as! [String : Any]
                    DataManager.shared.before = Helper.checkNull(dict["before"]) as? String ?? ""
                    DataManager.shared.before = Helper.checkNull(dict["after"]) as? String ?? ""

                    if dict["children"] != nil {
                        self.listings = RedditListing.init(children: dict["children"] as! Array<Dictionary<String, Any>>)
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                    }
                }
            }
            catch {
                print(error.localizedDescription)
            }
            
        }
        task.resume()
    }
}

