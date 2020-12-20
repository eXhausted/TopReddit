import UIKit
import Combine

typealias DataSource = UITableViewDiffableDataSource<Int, Post>
typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Post>

class TopViewController: UIViewController {
    
    private var subscriptions: Set<AnyCancellable> = .init()
    
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
        dataSoruce = .init(tableView: tableView, cellProvider: { [viewModel] (tableView, indexPath, model) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TopTableViewCell
            cell.viewModel = .init(model: model, imageService: viewModel.imageService)
            return cell
        })
        
        
        viewModel
            .$models
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.models.count - viewModel.limit {
            viewModel.nextPage()
        }
    }
}
