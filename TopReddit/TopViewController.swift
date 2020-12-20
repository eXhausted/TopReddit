import UIKit
import Combine

typealias DataSource = UITableViewDiffableDataSource<Int, TopTableViewCellModel>
typealias Snapshot = NSDiffableDataSourceSnapshot<Int, TopTableViewCellModel>

class TopViewController: UIViewController {
    
    var subscriptions: Set<AnyCancellable> = .init()
    
    let viewModel = TopViewModel()
    var dataSoruce: DataSource?
    
    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 300
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSoruce = .init(tableView: tableView, cellProvider: { [unowned self] (tableView, indexPath, viewModel) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TopTableViewCell
            
            cell.titleLabel?.text = viewModel.title
            cell.authorLabel?.text = viewModel.author
            cell.numberOfCommentsLabel?.text = viewModel.numberOfComments
            
            viewModel
                .$title
                .receive(on: DispatchQueue.main)
                .assign(to: \.text, on: cell.titleLabel)
                .store(in: &self.subscriptions)
            
            viewModel
                .$author
                .receive(on: DispatchQueue.main)
                .assign(to: \.text, on: cell.authorLabel)
                .store(in: &self.subscriptions)
            
            viewModel
                .$numberOfComments
                .receive(on: DispatchQueue.main)
                .assign(to: \.text, on: cell.numberOfCommentsLabel)
                .store(in: &self.subscriptions)
            
            viewModel
                .$image
                .receive(on: DispatchQueue.main)
                .breakpoint()
                .assign(to: \.image, on: cell.thumbnailImageView)
                .store(in: &self.subscriptions)
            
            cell.widthContraint?.constant = viewModel.imageSize.width
            cell.heightContraint?.constant = viewModel.imageSize.height
            
            return cell
        })
        
        
        viewModel
            .$viewModels
            .sink { [weak self] (models) in
                var snapshot = Snapshot()
                snapshot.appendSections([0])
                snapshot.appendItems(models, toSection: 0)
                self?.dataSoruce?.apply(snapshot)
                
            }
            .store(in: &subscriptions)
    }
}

extension TopViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
