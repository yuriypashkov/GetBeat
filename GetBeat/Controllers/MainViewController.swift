
import UIKit
import AVFoundation

class MainViewController: UIViewController, FilterDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var allTracksInTable: [[Track]] = [[]]
    var hotTracks: [Track] = []
    var tracks: [Track] = []
    var networkModel = NetworkModel()
    
    let activityIndicator = UIActivityIndicatorView()
    
    //background play music
    let player = AVPlayer()
    var playerItem: AVPlayerItem?
    private var playingTrackObserver: Any?
    private var loadingTrackObserver: Any?
    
    //array for query items
    var queryItems: [URLQueryItem] = []
    
    var playingView: PlayingView!
    
    // 2 запроса к бэку при старте приложения, поэтому такой выход для правильного выключения индикатора загрузки
    var indicatorCount = 0 {
        didSet {
            if indicatorCount > 0 {
                activityIndicator.startAnimating()
                tableView.isUserInteractionEnabled = false
            } else {
                activityIndicator.stopAnimating()
                tableView.isUserInteractionEnabled = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let tabBarHeight = tabBarController?.tabBar.frame.size.height {
            // playingView
            playingView = PlayingView(position: CGPoint(x: 0, y: view.frame.size.height - 75 - tabBarHeight), width: view.frame.size.width, height: 180)
            view.addSubview(playingView)
            playingView.alpha = 0
        } 
        
        // set indicator view
        activityIndicator.hidesWhenStopped = true
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        
        // load hot tracks
        loadHotTracks()
        
        // load regular tracks
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.isHidden = true
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
    
    func reloadDataInAllTracksArray() {
        allTracksInTable.removeAll()
        allTracksInTable.append(hotTracks)
        allTracksInTable.append(tracks)
        tableView.reloadData()
    }
    
    func loadHotTracks() {
        indicatorCount += 1
        
        networkModel.getHotTracks { (result) in
            DispatchQueue.main.async {
                switch result {
                    case .success(let array):
                        self.hotTracks = array
                        self.reloadDataInAllTracksArray()
                    case .failure:
                        self.hotTracks = []
                }
                self.indicatorCount -= 1
            }
        }
    }
    
    
    func loadData() {
        indicatorCount += 1
        
        networkModel.getTracks(queryItems: queryItems) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let tempArray):
                    self.tracks = tempArray
                    self.reloadDataInAllTracksArray()
                case .failure:
                    self.tracks = []
                    self.reloadDataInAllTracksArray()
                }
                self.indicatorCount -= 1
            }
        }
    }
    
    // аттрибут для подгрузки треков (значение на 10 меньше, нежели getCount, так работает бэк)
    var tracksCount = 0
    
    func lazyLoadData() {
        indicatorCount += 1
        
        let currentCount = tracksCount + 10
        // собираем массив параметров запроса. Добавляем к текущим параметрам фильтра прокрутку на 10 позиций каждый раз
        var lazyQueryItems = [
            URLQueryItem(name: "limit", value: String(currentCount))
        ]
        lazyQueryItems.append(contentsOf: queryItems)
        
        networkModel.getTracks(queryItems: lazyQueryItems) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let tempArray):
                    self.tracks.append(contentsOf: tempArray)
                    self.reloadDataInAllTracksArray()
        
                    if let tempIndexPath = self.tempIndexPath {
                        self.tableView.selectRow(at: tempIndexPath, animated: true, scrollPosition: .none)
                    }
                    
                    self.tracksCount += 10
                    self.indicatorCount -= 1
                case .failure:
                    self.indicatorCount -= 1
                }
            }
        }
        
    }
    
    // костыль для остановки текущего трека и воспроизведения следующего одним тапом
    var tempIndexPath: IndexPath?
    
    // MARK: Filtering
    
    @IBAction func filterButtonTap(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        if let filterViewController = storyboard.instantiateViewController(withIdentifier: "FilterViewController") as? FilterViewController {
            filterViewController.delegate = self
            filterViewController.filtersState = filterDictionaryForState
            present(filterViewController, animated: true, completion: nil)
        }
    }
    
    var filterDictionaryForState: [String: String?] = [:] // словарь удобней модели, ибо из него лучше делается массив queryItems
    
    func filterValuesSelected(filterDictionary: [String: String?]) {
        // назначаем параметры для массива queryItems и делаем релоад дата с этими параметрами
        queryItems.removeAll()
        tempIndexPath = nil // чтобы подсветка не оставалась после выставления фильтров
        filterDictionaryForState = filterDictionary // сохраним полученные значения фильтров, чтобы восстановить их при следующем входе в Фильтры
        
        for filterAttribute in filterDictionary {
            if let attributeValue = filterAttribute.value {
                queryItems.append(URLQueryItem(name: filterAttribute.key, value: attributeValue))
            }
        }
        loadData()
    }
    
    // MARK: - Search Button
    @IBAction func searchButtonTap(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        if let searchViewController = storyboard.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController {
            navigationController?.pushViewController(searchViewController, animated: true)
        }
    }
    
    
    
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return allTracksInTable.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.backgroundColor = .black
        label.textColor = .white
        label.textAlignment = .center
        switch section {
        case 0:
            label.text = "В ЦЕНТРЕ ВНИМАНИЯ"
        case 1:
            if tracks.count == 0 {
                label.text = "НИЧЕГО НЕ НАЙДЕНО"
            } else { label.text = "ВСЕ ТРЕКИ" }
        default: ()
        }
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allTracksInTable[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell") as! TrackCell
        cell.setCell(currentTrack: allTracksInTable[indexPath.section][indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // play music
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
            guard let durationInSeconds = allTracksInTable[indexPath.section][indexPath.row].durationInSeconds, !durationInSeconds.isNaN else {
                print("NaN ins seconds")
                return
            }

            // если нажал на новую ячейку
            preloadMusicData(urlString: allTracksInTable[indexPath.section][indexPath.row].previewUrl ?? "None")
            //show playing view
            playingView.player = player
            playingView.playPauseButton.setImage(UIImage(named: "pause60px"), for: .normal)
            playingView.authorNameLabel.text = allTracksInTable[indexPath.section][indexPath.row].authorName
            playingView.trackNameLabel.text = allTracksInTable[indexPath.section][indexPath.row].trackName
            playingView.endTimeValueLabel.text = allTracksInTable[indexPath.section][indexPath.row].durationInString
            playingView.beginTimeValueLabel.text = "0:00"
            
            // наблюдатель для загрузки трека, работает только при прокрутке грузящегося трека
//            if let lto = loadingTrackObserver {
//                player.removeTimeObserver(lto)
//                loadingTrackObserver = nil
//            }
//            
//            loadingTrackObserver = player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 10), queue: DispatchQueue.main, using: { [weak self] time in
//                if self?.player.currentItem?.status == .readyToPlay {
//                    if let isPlaybackLikelyToKeepUp = self?.player.currentItem?.isPlaybackLikelyToKeepUp {
//                        if !isPlaybackLikelyToKeepUp {
//                            self?.activityIndicator.startAnimating()
//                        } else {
//                            self?.activityIndicator.stopAnimating()
//                        }
//                    }
//                }
//            })
            
            // наблюдатель для работы со слайдером
            if let pto = playingTrackObserver {
                player.removeTimeObserver(pto)
                playingTrackObserver = nil
            }
            
            playingTrackObserver = player.addProgressObserver(action: { (progress) in
                self.playingView.durationSlider.value = Float(progress * durationInSeconds)
                self.playingView.beginTimeValueLabel.text = self.playingView.durationSlider.value.floatToTime()
            })
            
            playingView.durationSlider.maximumValue = Float(durationInSeconds) // на медленном соединении здесь значение NaN
            playingView.durationSlider.value = 0
            
            playingView.alpha = 1
            
            player.play()
            tempIndexPath = indexPath
        }
        
    }
    
    // подгрузка данных при прокрутке в самый низ таблицы
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset < 10.0 {
            lazyLoadData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
}

