import UIKit
import Combine

class TopTableViewCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var thumbnailImageView: UIImageView!
    @IBOutlet var numberOfCommentsLabel: UILabel!
    
    @IBOutlet var widthContraint: NSLayoutConstraint!
    @IBOutlet var heightContraint: NSLayoutConstraint!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel?.text = ""
        authorLabel?.text = ""
        thumbnailImageView?.image = nil
        numberOfCommentsLabel?.text = ""
        
    }
}
