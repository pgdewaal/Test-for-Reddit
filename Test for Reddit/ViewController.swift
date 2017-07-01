//
//  ViewController.swift
//  Test for Reddit
//
//  Created by Paul Dewaal on 6/24/17.
//  Copyright © 2017 Paul Dewaal. All rights reserved.
//

import UIKit

extension URL {
    func getDictionaryOfUrlQueries() -> Dictionary<String, String>? {
        let dict = NSMutableDictionary.init()
        if let array = self.query?.components(separatedBy: "&") {
            for query in array {
                let key = query.components(separatedBy: "=").first
                let value = query.components(separatedBy: "=").last
                dict.setValue(value, forKey: key!)
            }
        }
        return dict as? Dictionary<String, String>
    }
}

class FooterView : UICollectionReusableView {
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class ViewController: UIViewController, UIWebViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var loginView: UIWebView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var listings : RedditListing?
    var isMakingRequest : Bool
    
    required init?(coder aDecoder: NSCoder) {
        isMakingRequest = false
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("url: \(DataManager.shared.redirectUrl)")
        print("encoded: \(DataManager.shared.redirectUrlEncoded())");
        self.attemptLogin()
        listings = DataManager.shared.top
        
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
         return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listings != nil ? listings!.items.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.size.width/2
        return CGSize(width: width, height: width*(9.0/16.0));
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "redditCell", for: indexPath as IndexPath) as! RedditCollectionCell
        if let link = listings?.items[indexPath.row] {
            cell.updateCell(forRedditLink: link)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footerView", for: indexPath)
        if kind == UICollectionElementKindSectionFooter && DataManager.shared.accessToken != nil {
            getTop50()
        }

        return footer
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
            RedditRequestCreater.makeAuthorizationRequest(completion: { (success) in
                if success {
                    self.getTop50()
                }
                else {
                    self.showError()
                }
            })
        }
        else {
            showError()
        }
    }
    
    func getTop50() {
        if isMakingRequest {
            return
        }
        isMakingRequest = true
        RedditRequestCreater.makeTop50Request(completion: { (success) in
            if success {
                self.collectionView.reloadData()
            }
            else {
                self.showError()
            }
            self.isMakingRequest = false
        })
    }
    
    private func showError() {
        let alert = UIAlertController.init(title: "Error", message: "Only supporting the happy path, please try again", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction.init(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
            self.loginView.alpha = 1
            self.attemptLogin()
        }))
        self.present(alert, animated: true, completion: {
            
        })
    }
}

