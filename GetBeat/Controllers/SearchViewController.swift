
import UIKit
import AVFoundation

class SearchViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var filteredTracks: [Track] = []
    let networkModel = NetworkModel()
    let activityIndicator = UIActivityIndicatorView()
    
    //attributes for playing music
    var playingView: PlayingView!
    let player = AVPlayer()
    var playerItem: AVPlayerItem?
    private var playingTrackObserver: Any?
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.isHidden = false
        NotificationCenter.default.addObserver(self, selector: #selector(didFinishPlayTrack(sender:)), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        
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
    }
    
    func preloadMusicData(urlString: String) {
        let url = URL(string: urlString)
        let playerItem = AVPlayerItem(url: url!)
        player.replaceCurrentItem(with: playerItem)
    }
    
    @objc func didFinishPlayTrack(sender: Notification) {
        playingView.setViewOnDefault()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.hidesWhenStopped = true
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        
        //searchbar settings
        searchBar.delegate = self
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
        searchBar.becomeFirstResponder()
        
        // playingView
        playingView = PlayingView(position: CGPoint(x: 0, y: view.frame.size.height - 90), width: view.frame.size.width, height: 180)
        view.addSubview(playingView)
        playingView.alpha = 0
        
    }
    
    func search(query: String) {
        activityIndicator.startAnimating()
        networkModel.search(queryString: query) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let array):
                    self.filteredTracks = array
                    self.activityIndicator.stopAnimating()
                    self.tableView.reloadData()
                    //self.tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
                    self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                    self.title = "Найдено треков: \(self.filteredTracks.count)"
                case .failure:
                    self.filteredTracks = []
                    self.activityIndicator.stopAnimating()
                    self.tableView.reloadData()
                    self.title = "Ничего не найдено"
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
        if let query = searchBar.text, query.count >= 2 {
            search(query: query)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tempIndexPath == indexPath {
            
            // если нажал на ту же самую ячейку
            if player.timeControlStatus == .playing {
                player.pause()
                playingView.playPauseButton.setImage(UIImage(named: "play60px"), for: .normal)
            } else {
                playingView.alpha = 1
                player.play()
                playingView.playPauseButton.setImage(UIImage(named: "pause60px"), for: .normal)
            }
            
        } else {
            guard let durationInSeconds = filteredTracks[indexPath.row].durationInSeconds, !durationInSeconds.isNaN else {
                return
            }
            
            if let ob = self.playingTrackObserver {
                player.removeTimeObserver(ob)
                playingTrackObserver = nil
            }
            
            // если нажал на новую ячейку
            preloadMusicData(urlString: filteredTracks[indexPath.row].previewUrl ?? "None")
            
            //show playing view
            playingView.player = player
            playingView.playPauseButton.setImage(UIImage(named: "pause60px"), for: .normal)
            playingView.authorNameLabel.text = filteredTracks[indexPath.row].authorName
            playingView.trackNameLabel.text = filteredTracks[indexPath.row].trackName
            playingView.endTimeValueLabel.text = filteredTracks[indexPath.row].durationInString
            playingView.beginTimeValueLabel.text = "0:00"
            
            //if let durationInSeconds = filteredTracks[indexPath.row].durationInSeconds {
                playingView.durationSlider.maximumValue = Float(durationInSeconds)
                playingView.durationSlider.value = 0
                
                playingTrackObserver = player.addProgressObserver(action: { (progress) in
                    self.playingView.durationSlider.value = Float(progress * durationInSeconds)
                    self.playingView.beginTimeValueLabel.text = self.playingView.durationSlider.value.floatToTime()
                })
                
            //}
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
    
    
}
