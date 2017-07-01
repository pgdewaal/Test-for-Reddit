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
    
    var listing : RedditListing = RedditListing.init()
    var isMakingRequest : Bool
    var refresh : UIRefreshControl = UIRefreshControl.init()
    
    required init?(coder aDecoder: NSCoder) {
        isMakingRequest = false
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("url: \(DataManager.shared.redirectUrl)")
        print("encoded: \(DataManager.shared.redirectUrlEncoded())");
        self.attemptLogin()
        collectionView.alwaysBounceVertical = true
        refresh.tintColor = UIColor.red
        refresh.addTarget(self, action: #selector(refreshListing), for: UIControlEvents.valueChanged)
        collectionView.addSubview(refresh)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let path = collectionView.indexPathsForVisibleItems.first
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.reloadData()

        if let path = path {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
                self.collectionView.scrollToItem(at: path, at: UICollectionViewScrollPosition.top, animated: true)
            })
        }
    }
    
    // MARK: - CollectionView Methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
         return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listing.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width = UIScreen.main.bounds.size.width
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight:
             width = UIScreen.main.bounds.size.width*0.45
            break;
        default:
            break;
        }
        return CGSize(width: width, height: width*(9.0/16.0));
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "redditCell", for: indexPath as IndexPath) as! RedditCollectionCell
        cell.updateCell(forRedditLink: listing.items[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footerView", for: indexPath)
        if kind == UICollectionElementKindSectionFooter && DataManager.shared.accessToken != nil {
            getTop50(after: listing.items.last?.fullname, before: nil)
        }

        return footer
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let link = listing.items[indexPath.row]
        if link.hasFullImage {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "fullscreenImageVC") as! FullScreenImageVC
            controller.link = link
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    // MARK: - Request Methods
    
    func getTop50(after: String?, before: String?) {
        if isMakingRequest {
            return
        }
        isMakingRequest = true
        RedditRequestCreater.shared.makeTop50Request(listing: listing, after: after, before: before) { (success) in
            if success {
                self.collectionView.reloadData()
            }
            else {
                self.showError()
            }
            self.isMakingRequest = false
        }
    }
    
    func getUser() {
        RedditRequestCreater.shared.getUser(completion: { (success) in
            if success {
                guard let user = DataManager.shared.user else {
                    self.getTop50(after: nil, before: nil)
                    return
                }
                self.listing.retrieveItemsForUser(user)
                
                if self.listing.items.count == 0 {
                    self.getTop50(after: nil, before: nil)
                }
                else {
                    self.collectionView.reloadData()
                }
            }
            else {
                self.showError()
            }
        })
    }
    
    func refreshListing() {
        RedditRequestCreater.shared.refreshTop50Request(listing: listing) { (success) in
            self.refresh.endRefreshing()
            if success {
                self.collectionView.reloadData()
            }
            else {
                self.showError()
            }
        }
    }
    
    // MARK: - Public/Private Methods
    
    func userInputReceived(success:Bool) {
        self.loginView.alpha = 0
        
        if success && DataManager.shared.userCode != nil {
            RedditRequestCreater.shared.makeAuthorizationRequest(completion: { (success) in
                if success {
                    self.getUser()
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
    
    private func attemptLogin() {
        let login = URLRequest.init(url: URL.init(string: "https://www.reddit.com/api/v1/authorize.compact?client_id=6swhF9VsKjCyEQ&response_type=code&state=\(DataManager.shared.state)&redirect_uri=\(DataManager.shared.redirectUrlEncoded())&duration=permanent&scope=read%20identity")!)
        loginView.loadRequest(login)
    }
    
    private func showError() {
        let alert = UIAlertController.init(title: "Error", message: "Only supporting the happy path, please try again", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction.init(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
            if DataManager.shared.user == nil{
                self.loginView.alpha = 1
                self.attemptLogin()
            }
        }))
        self.present(alert, animated: true, completion: {
            
        })
    }
}

