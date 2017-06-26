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


class ViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var loginView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("url: \(DataManager.shared.redirectUrl)")
        print("encoded: \(DataManager.shared.redirectUrlEncoded())");
        let login = URLRequest.init(url: URL.init(string: "https://www.reddit.com/api/v1/authorize.compact?client_id=6swhF9VsKjCyEQ&response_type=code&state=\(DataManager.shared.state)&redirect_uri=\(DataManager.shared.redirectUrlEncoded())&duration=permanent&scope=read")!)
        loginView.loadRequest(login)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

