
import UIKit
import AVFoundation

class SearchViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableViewBottom: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    
    
    var filteredTracks: [Track] = []
    let networkModel = NetworkModel()
    let searchCustomActivityIndicator = CustomActivityIndicator()
    
    var tabBar: CustomTabBarController?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
         return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // activity indicator setup
        searchCustomActivityIndicator.animate()
        searchCustomActivityIndicator.alpha = 0
        searchCustomActivityIndicator.center = CGPoint(x: view.frame.width / 2 - 70, y: view.frame.height / 2)
        view.addSubview(searchCustomActivityIndicator)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        searchBar.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        searchCustomActivityIndicator.stopAnimate()
        searchCustomActivityIndicator.removeFromSuperview()
    }


    @IBAction func cancelButtonTap(_ sender: UIButton) {
        //dismiss(animated: true, completion: nil)
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set tabBarController
        tabBar = tabBarController as? CustomTabBarController
        
        //searchbar settings
        searchBar.delegate = self
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    func search(query: String) {
        tempIndexPath = nil // чтобы при повторном поиске не было косяков
        searchCustomActivityIndicator.alpha = 1
        networkModel.search(queryString: query) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let array):
                    self.filteredTracks = array
                    self.searchCustomActivityIndicator.alpha = 0
                    self.tableView.reloadData()
                    self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                    self.titleLabel.text = "Найдено треков: \(self.filteredTracks.count)"
                case .failure:
                    self.filteredTracks = []
                    self.searchCustomActivityIndicator.alpha = 0
                    self.tableView.reloadData()
                    self.titleLabel.text = "Ничего не найдено"
                }
            }
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    var tempIndexPath: IndexPath?
    
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let query = searchBar.text, query.count >= 3 {
            search(query: query)
            dismissKeyboard()
        } else {
            titleLabel.text = "Строка поиска слишком мала"
            searchCustomActivityIndicator.alpha = 0
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tabBar?.isAnimatingStoped = false
        tabBar?.player.pause()
        
        if tableViewBottom.constant == 0 {
            tableViewBottom.constant = 90
        }
        if tempIndexPath == indexPath {

            // если нажал на ту же самую ячейку
            if tabBar?.player.timeControlStatus == .playing {
                tabBar?.player.pause()
                tabBar?.playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            } else {
                //playingView.alpha = 1
                tabBar?.player.play()
                tabBar?.playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            }

        } else {
            // если нажал на новую ячейку
            tabBar?.containerView.alpha = 1
            tabBar?.setPlayingView(currentTrack: filteredTracks[indexPath.row])
            tabBar?.startAnimating()
            tabBar?.preloadMusicData(urlString: filteredTracks[indexPath.row].previewUrl ?? "None")
            tabBar?.createDurationObserver(currentTrack: filteredTracks[indexPath.row])
            tabBar?.player.play()
            tempIndexPath = indexPath
        }
    }



    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTracks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell") as! TrackCell
        cell.setCell(currentTrack: filteredTracks[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return ContextMenuModel.createMenu(currentTrack: filteredTracks[indexPath.row])
    }


}
