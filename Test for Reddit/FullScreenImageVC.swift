//
//  FullScreenImageVC.swift
//  Test for Reddit
//
//  Created by Paul Dewaal on 6/27/17.
//  Copyright © 2017 Paul Dewaal. All rights reserved.
//

import UIKit

class FullScreenImageVC : UIViewController {
    
    var link : RedditLink?
    @IBOutlet weak var imgView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        link?.fullsize(completion: { (image) in
            self.imgView.image = image
        })
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
