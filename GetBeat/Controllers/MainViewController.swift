
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
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    
    //array for query items
    var queryItems: [URLQueryItem] = []
    
    var playingView: PlayingView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // playingView
        playingView = PlayingView(position: CGPoint(x: 0, y: view.frame.size.height - 90), width: view.frame.size.width, height: 180)
        view.addSubview(playingView)
        playingView.alpha = 0
        
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
        navigationController?.navigationBar.isHidden = true
    }
    
    func preloadMusicData(urlString: String) {
        let url = URL(string: urlString)
        let playerItem = AVPlayerItem(url: url!)
        player = AVPlayer(playerItem: playerItem)
    }
    
    func worksWithArray() {
        allTracksInTable.removeAll()
        allTracksInTable.append(hotTracks)
        allTracksInTable.append(tracks)
        activityIndicator.stopAnimating()
        tableView.reloadData()
    }
    
    func loadHotTracks() {
        activityIndicator.startAnimating()
        networkModel.getHotTracks { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let array):
                    self.hotTracks = array
                    self.worksWithArray()
                case .failure:
                    self.hotTracks = []
                    self.activityIndicator.stopAnimating()
            }
        }
    }
    }
    
    
    func loadData() {
        activityIndicator.startAnimating()
        
        networkModel.getTracks(queryItems: queryItems) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let tempArray):
                    self.tracks = tempArray
                    self.worksWithArray()
                case .failure:
                    self.tracks = []
                    self.worksWithArray()
                }
            }
        }
    }
    
    // аттрибут для подгрузки треков (значение на 10 меньше, нежели getCount, так работает бэк)
    var tracksCount = 0
    
    func lazyLoadData() {
        
        activityIndicator.startAnimating()
        
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
                    
                    self.worksWithArray()
                    
                    if let tempIndexRow = self.tempIndexRow {
                        self.tableView.selectRow(at: IndexPath(row: tempIndexRow, section: 1), animated: true, scrollPosition: .none)
                    }
                    
                    self.tracksCount += 10
                case .failure:
                    self.activityIndicator.stopAnimating()
                }
            }
        }
        
    }
    
    // костыль для остановки текущего трека и воспроизведения следующего одним тапом
    var tempIndexRow: Int?
    
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
        tempIndexRow = nil // чтобы подсветка не оставалась после выставления фильтров
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
        if indexPath.row == tempIndexRow {
            // если нажал на ту же самую ячейку
            if player?.timeControlStatus == .playing {
                player?.pause()
                playingView.playPauseButton.setImage(UIImage(named: "play60px"), for: .normal)
            } else {
                player?.play()
                playingView.playPauseButton.setImage(UIImage(named: "pause60px"), for: .normal)
            }
            
        } else {
            // если нажал на новую ячейку
            preloadMusicData(urlString: tracks[indexPath.row].previewUrl ?? "None")
            
            //show playing view
            playingView.player = player
            playingView.playPauseButton.setImage(UIImage(named: "pause60px"), for: .normal)
            playingView.authorNameLabel.text = tracks[indexPath.row].authorName
            playingView.trackNameLabel.text = tracks[indexPath.row].trackName
            playingView.alpha = 1
            
            player?.play()
            tempIndexRow = indexPath.row
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

