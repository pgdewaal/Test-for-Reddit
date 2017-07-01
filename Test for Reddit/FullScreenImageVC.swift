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
    @IBOutlet weak var btnSave: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        btnSave.isUserInteractionEnabled = false
        link?.fullsize(completion: { (image) in
            self.btnSave.isUserInteractionEnabled = true
            self.imgView.image = image
        })
    }
    
    @IBAction func savedTapped(_ sender: Any) {
        btnSave.isUserInteractionEnabled = false
        if let image = imgView.image {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        btnSave.isUserInteractionEnabled = true
        if let error = error as NSError? {
            var message = error.localizedDescription
            if error.code == -3310 {
                message = "Please turn on photos access for this app in the settings menu."
            }
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
        else {
            let alert = UIAlertController(title: "Saved", message: "The image was saved to your album.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}
