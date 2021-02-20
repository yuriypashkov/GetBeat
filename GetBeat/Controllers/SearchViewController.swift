
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
    
    //attributes for playing music
    var playingView: PlayingView!
    let player = AVPlayer()
    var playerItem: AVPlayerItem?
    private var playingTrackObserver: Any?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
         return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(didFinishPlayTrack(sender:)), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        // activity indicator setup
        searchCustomActivityIndicator.animate()
        searchCustomActivityIndicator.alpha = 0
        view.addSubview(searchCustomActivityIndicator)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        searchBar.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if let ob = self.playingTrackObserver {
            player.removeTimeObserver(ob)
            playingTrackObserver = nil
        }

        player.pause()
        playingView.alpha = 0
        playingView.setViewOnDefault()
        
        NotificationCenter.default.removeObserver(self)
        
        searchCustomActivityIndicator.stopAnimate()
        searchCustomActivityIndicator.removeFromSuperview()
    }
    
    func preloadMusicData(urlString: String) {
        let url = URL(string: urlString)
        let playerItem = AVPlayerItem(url: url!)
        player.replaceCurrentItem(with: playerItem)
    }
    
    @objc func didFinishPlayTrack(sender: Notification) {
        playingView.setViewOnDefault()
    }
    
    
    @IBAction func cancelButtonTap(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //searchbar settings
        searchBar.delegate = self
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
        
        // playingView
        playingView = PlayingView(position: CGPoint(x: 0, y: view.frame.size.height - 90), width: view.frame.size.width, height: 180)
        view.addSubview(playingView)
        playingView.alpha = 0
        
    }
    
    func search(query: String) {
        searchCustomActivityIndicator.center = CGPoint(x: view.frame.width / 2 - 70, y: view.frame.height / 2) // при каждом поиске размещаем по центру индикатор, дабы не было проблем при смене ориенитации телефона в пространстве
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
    var isAnimatingStopped = false
    
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
        isAnimatingStopped = false
        if tableViewBottom.constant == 0 {
            tableViewBottom.constant = 90
        }
        if tempIndexPath == indexPath {

            // если нажал на ту же самую ячейку
            if player.timeControlStatus == .playing {
                player.pause()
                playingView.playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            } else {
                playingView.alpha = 1
                player.play()
                playingView.playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            }

        } else {
            guard let duration = filteredTracks[indexPath.row].duration else {
                return
            }
            
            playingView.startAnimating()

            if let ob = self.playingTrackObserver {
                player.removeTimeObserver(ob)
                playingTrackObserver = nil
            }

            // если нажал на новую ячейку
            preloadMusicData(urlString: filteredTracks[indexPath.row].previewUrl ?? "None")

            //show playing view
            playingView.player = player
            playingView.playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            playingView.authorNameLabel.text = filteredTracks[indexPath.row].authorName
            playingView.trackNameLabel.text = filteredTracks[indexPath.row].trackName
            playingView.endTimeValueLabel.text = filteredTracks[indexPath.row].durationInString
            playingView.beginTimeValueLabel.text = "0:00"

                playingView.durationSlider.maximumValue = Float(duration)
                playingView.durationSlider.value = 0

                playingTrackObserver = player.addProgressObserver(action: { (progress) in
                    if progress > 0, !self.isAnimatingStopped {
                        self.playingView.stopAnimating()
                        self.isAnimatingStopped = true
                    }
                    self.playingView.durationSlider.value = Float(progress * duration)
                    self.playingView.beginTimeValueLabel.text = self.playingView.durationSlider.value.floatToTime()
                })

            playingView.alpha = 1

            player.play()
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
