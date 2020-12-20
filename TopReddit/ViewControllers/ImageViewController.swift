import UIKit
import Combine

class ImageViewController: UIViewController {
    
    private var subscriptions: Set<AnyCancellable> = .init()
    @IBOutlet var imageView: UIImageView!
    var viewModel: ImageViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?
            .$image
            .receive(on: DispatchQueue.main)
            .assign(to: \.image, on: imageView)
            .store(in: &subscriptions)
    }
    
    @IBAction func shareButtonAction(sender: UIBarButtonItem) {
        guard let image = imageView.image, let url = viewModel?.imageData.url else { return }
        let ac = UIActivityViewController(activityItems: [image, url.absoluteString], applicationActivities: nil)
        present(ac, animated: true)
    }
}
