import UIKit
import Combine

class TopTableViewCell: UITableViewCell {
    
    private var subscriptions: Set<AnyCancellable> = .init()
    
    var viewModel: TopTableViewCellModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            
            titleLabel?.text = viewModel.title
            authorLabel?.text = viewModel.author
            numberOfCommentsLabel?.text = viewModel.numberOfComments
            
            viewModel
                .$title
                .receive(on: DispatchQueue.main)
                .assign(to: \.text, on: titleLabel)
                .store(in: &self.subscriptions)
            
            viewModel
                .$author
                .receive(on: DispatchQueue.main)
                .assign(to: \.text, on: authorLabel)
                .store(in: &self.subscriptions)
            
            viewModel
                .$numberOfComments
                .receive(on: DispatchQueue.main)
                .assign(to: \.text, on: numberOfCommentsLabel)
                .store(in: &self.subscriptions)
            
            viewModel
                .$image
                .receive(on: DispatchQueue.main)
                .assign(to: \.image, on: thumbnailImageView)
                .store(in: &self.subscriptions)
            
            widthContraint?.constant = viewModel.imageSize.width
            heightContraint?.constant = viewModel.imageSize.height
        }
    }
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var thumbnailImageView: UIImageView!
    @IBOutlet var numberOfCommentsLabel: UILabel!
    
    @IBOutlet var widthContraint: NSLayoutConstraint!
    @IBOutlet var heightContraint: NSLayoutConstraint!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel = nil
        titleLabel?.text = ""
        authorLabel?.text = ""
        thumbnailImageView?.image = nil
        numberOfCommentsLabel?.text = ""        
    }
}
