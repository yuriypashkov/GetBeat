
import UIKit
import AVFoundation

class MainViewController: UIViewController, FilterDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var tracks: [Track] = []
    var networkModel = NetworkModel()
    
    let activityIndicator = UIActivityIndicatorView()
    
    //background play music
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    
    //array for query items
    var queryItems: [URLQueryItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set indicator view
        activityIndicator.hidesWhenStopped = true
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()

        // load data
        loadData()
    }
    
    func preloadMusicData(urlString: String) {
        let url = URL(string: urlString)
        let playerItem = AVPlayerItem(url: url!)
        player = AVPlayer(playerItem: playerItem)
    }
    
    
    func loadData() {
        
//        let queryItemsForStart = [
//            URLQueryItem(name: "mobileApp", value: "1"),
//            URLQueryItem(name: "getCount", value: "20")
//        ]
        
        networkModel.getTracks(queryItems: queryItems) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let tempArray):
                    self.tracks = tempArray
                    self.tableView.reloadData()
                    self.activityIndicator.stopAnimating()
                case .failure:
                    self.tracks = []
                    self.activityIndicator.stopAnimating()
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
                    self.activityIndicator.stopAnimating()
                    self.tableView.reloadData()
                    
                    if let tempIndexRow = self.tempIndexRow {
                        self.tableView.selectRow(at: IndexPath(row: tempIndexRow, section: 0), animated: true, scrollPosition: .none)
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
            present(filterViewController, animated: true, completion: nil)
        }
    }
    
    func filterValuesSelected(filterDictionary: [String: String?]) {
        // назначаем параметры для массива queryItems и делаем релоад дата с этими параметрами
        queryItems.removeAll()
        
        for filterAttribute in filterDictionary {
            if let attributeValue = filterAttribute.value {
                queryItems.append(URLQueryItem(name: filterAttribute.key, value: attributeValue))
            }
        }
        print(queryItems)
        loadData()
    }
    
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell") as! TrackCell
        cell.setCell(currentTrack: tracks[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // play music
        if player?.timeControlStatus == .playing, indexPath.row == tempIndexRow {
            player?.pause()
        } else {
            preloadMusicData(urlString: tracks[indexPath.row].previewUrl ?? "None")
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

