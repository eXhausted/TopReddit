import UIKit
import Combine

typealias DataSource = TableViewDataSource<Post>

class TopViewController: UIViewController {
    
    private var subscriptions: Set<AnyCancellable> = .init()
    
    let viewModel = TopViewModel()
    var dataSoruce: DataSource!
    
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel
            .$models
            .receive(on: DispatchQueue.global())
            .receive(subscriber: dataSoruce)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            let model = sender as? Post,
            let viewController = segue.destination as? ImageViewController,
            let imageData = model.data.preview?.images.first?.source else { return }
        
        viewController.viewModel = .init(imageData: imageData, imageService: viewModel.imageService)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let model = dataSoruce?.item(at: indexPath) else { return }
        performSegue(withIdentifier: "ImageViewControllerSegue", sender: model)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
