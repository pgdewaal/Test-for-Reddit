//
//  RedditCollectionCell.swift
//  Test for Reddit
//
//  Created by Paul Dewaal on 6/26/17.
//  Copyright © 2017 Paul Dewaal. All rights reserved.
//

import Foundation
import UIKit

class RedditCollectionCell : UICollectionViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblAuthor: UILabel!
    @IBOutlet weak var lblComment: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var imgThumb: UIImageView!
    
    var lastTouch : Double
    
    required init?(coder aDecoder: NSCoder) {
        lastTouch = 0
        super.init(coder: aDecoder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        lblTitle.text = ""
        lblAuthor.text = ""
        lblComment.text = ""
        lblDate.text = ""
        imgThumb.image = nil
        setLabelsAlpha(1)
    }
    
    func updateCell(forRedditLink:RedditLink) {
        lblTitle.text = forRedditLink.title //So I know you said "at it's full length"; but the reality is (IMO) that there is a "max size" that the UI designer won't allow it to grow any larger by. I can easily adjust the constraint to be however big I want, to make it feasible; but I've chosen to limit it to just 4 lines.
        lblAuthor.text = String.init("by \(forRedditLink.author)")
        lblComment.text = String.init("\(forRedditLink.commentsCount) comment\(forRedditLink.commentsCount == 1 ? "" : "s")")
        
        let hours = Helper.hoursFromNow(withDate:forRedditLink.entryDate)
        if hours < 24 {
            lblDate.text = String.init(format: "\(hours) hour\(hours == 1 ? "" : "s") ago")
        }
        else {
            let formatter = DateFormatter.init()
            formatter.dateStyle = DateFormatter.Style.short
            formatter.doesRelativeDateFormatting = true
            lblDate.text = forRedditLink.entryDate == nil ? "unknown" : formatter.string(from: forRedditLink.entryDate!)
        }

        forRedditLink.thumbnail { (image) in
            self.imgThumb.image = image
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        lastTouch = CACurrentMediaTime()
        setLabelsAlpha(0)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if CACurrentMediaTime() - lastTouch < 0.5 { //Registers as a "tap", so you have to "tap" to select a cell. This makes it so when you press and hold to view the thumbnail, when you release it doesn't automatically take you to the fullscreen picture
            super.touchesEnded(touches, with: event)
        }
        else {
            super.touchesCancelled(touches, with: event)    
        }
        setLabelsAlpha(1)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        setLabelsAlpha(1)
    }
    
    private func setLabelsAlpha(_ alpha: CGFloat) {
        if imgThumb.image != nil {
            lblTitle.alpha = alpha
            lblAuthor.alpha = alpha
            lblComment.alpha = alpha
            lblDate.alpha = alpha
        }
    }
}
