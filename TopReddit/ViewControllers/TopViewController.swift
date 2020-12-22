import UIKit
import Combine

typealias DataSource = TableViewDataSource<Post>

class TopViewController: UIViewController {
    
    private var subscriptions: Set<AnyCancellable> = .init()
    
    let viewModel = DependencyContainer.container.resolve()
    var dataSoruce: DataSource!
    
    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 300
        }
    }
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        [UIApplication.willTerminateNotification, UIApplication.didEnterBackgroundNotification]
            .publisher
            .flatMap { NotificationCenter.default.publisher(for: $0) }
            .sink { [unowned self] (value) in
                let post = self.tableView
                    .visibleCells
                    .compactMap { $0 as? TopTableViewCell }
                    .filter { $0.convert($0.bounds.origin, to: self.view).y > 0 }
                    .compactMap { $0.viewModel}
                    .map { $0.post }
                    .first
                
                post.map(self.viewModel.persist(from:))
            }
            .store(in: &subscriptions)
        
        dataSoruce = .init(tableView: tableView, cellProvider: { (tableView, indexPath, model) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TopTableViewCell
            cell.viewModel = DependencyContainer.container.resolve(with: model)
            return cell
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel
            .$models
            .zip(viewModel.$scrollTo)
            .receive(on: DispatchQueue.main)
            .filter { !$0.0.isEmpty && $0.1 != NSNotFound }
            .map { $0.1 }
            .assign(to: \.scrollTo, on: dataSoruce)
            .store(in: &subscriptions)
        
        let publisher = viewModel
            .$models
            .receive(on: DispatchQueue.global())
        
        publisher
            .combineLatest(Just(refreshControl))
            .receive(on: DispatchQueue.main)
            .filter{ (_, refreshControl) in refreshControl.isRefreshing }
            .sink { (_, refreshControl) in
                refreshControl.endRefreshing()
            }
            .store(in: &subscriptions)
        
        publisher
            .receive(subscriber: dataSoruce)
        
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(reload), for: .valueChanged)
    }
    
    @IBAction func reload(_ sender: Any) {
        viewModel.reload()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            let model = sender as? Post,
            let viewController = segue.destination as? ImageViewController,
            let imageData = model.data.preview?.images.first?.source else { return }
        
        viewController.viewModel = DependencyContainer.container.resolve(with: imageData)
    }
}

extension TopViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let height = viewModel.height(at: indexPath.row) else { return UITableView.automaticDimension }
        return CGFloat(height)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.models.count - viewModel.limit {
            viewModel.nextPage()
        }
        viewModel.handle(height: Double(cell.bounds.height), index: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let model = dataSoruce?.item(at: indexPath) else { return }
        performSegue(withIdentifier: "ImageViewControllerSegue", sender: model)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
