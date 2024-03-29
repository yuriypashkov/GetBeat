
import UIKit
import AVFoundation

class MainViewController: UIViewController, FilterDelegate {
    
    @IBOutlet weak var reloadButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var allTracksInTable: [[Track]] = [[]]
    var hotTracks: [Track] = []
    var tracks: [Track] = []
    var networkModel = NetworkModel()
    
    var hideWelcomeViewController = false
    
    weak var hotTracksProtocolDelegate: HotTracksPageControllerDelegate?
    var customActivityIndicator = CustomActivityIndicator()
    
    //background play music
    let player = AVPlayer()
    var playerItem: AVPlayerItem?
    private var playingTrackObserver: Any?
    
    //array for query items
    var queryItems: [URLQueryItem] = []
    
    var playingView: PlayingView!
    
    // 2 запроса к бэку при старте приложения, поэтому такой выход для правильного выключения индикатора загрузки
    var indicatorCount = 0 {
        didSet {
            customActivityIndicator.center = CGPoint(x: view.frame.width / 2 - 70, y: view.frame.height / 2)
            if indicatorCount > 0 {
                customActivityIndicator.alpha = 1.0
                tableView.isUserInteractionEnabled = false
            } else {
                customActivityIndicator.alpha = 0.0
                tableView.isUserInteractionEnabled = true
            }
        }
    }
    let defaults = UserDefaults.standard

    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideWelcomeViewController = defaults.bool(forKey: "hideWelcomeViewController")
        //print(showWelcomeViewController)
        if let tabBarHeight = tabBarController?.tabBar.frame.size.height, let window = UIApplication.shared.windows.first {
            // playingView
            let bottomInset = view.frame.size.height - tabBarHeight - window.safeAreaInsets.bottom - 75
            playingView = PlayingView(position: CGPoint(x: 0, y: bottomInset), width: view.frame.size.width, height: 180)
            view.addSubview(playingView)
            playingView.alpha = 0
        }
        
        // load hot tracks
        loadHotTracks()
        
        // load regular tracks
        loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //show welcome controller
        if !hideWelcomeViewController {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let welcomeViewController = storyboard.instantiateViewController(withIdentifier: "WelcomeViewController") as! WelcomeViewController
            present(welcomeViewController, animated: true, completion: nil)
            hideWelcomeViewController = true
            defaults.setValue(hideWelcomeViewController, forKey: "hideWelcomeViewController")
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
         return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(didFinishPlayTrack(sender:)), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        // set indicator view
        customActivityIndicator.animate()
        view.addSubview(customActivityIndicator)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        customActivityIndicator.stopAnimate()
        customActivityIndicator.removeFromSuperview()
    }
    
    private func methodForDisappear() {
        if let ob = self.playingTrackObserver {
            player.removeTimeObserver(ob)
            playingTrackObserver = nil
        }
        
        player.pause()
        playingView.alpha = 0
        playingView.setViewOnDefault()
        
        NotificationCenter.default.removeObserver(self)
    
    }
    
    // MARK: - AVPlayer Methods
    
    func preloadMusicData(urlString: String) {
        let url = URL(string: urlString)
        let playerItem = AVPlayerItem(url: url!)
        player.replaceCurrentItem(with: playerItem)
    }
    
    @objc func didFinishPlayTrack(sender: Notification) {
        playingView.setViewOnDefault()
    }
    
    func setAlphaOnError(_ value: CGFloat) {
        errorLabel.alpha = value
        reloadButton.alpha = value
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
                        self.hotTracksProtocolDelegate?.setNumberOfPages(numberOfPages: self.hotTracks.count)
                        self.setAlphaOnError(0)
                    case .failure:
                        self.hotTracks = []
                        self.setAlphaOnError(1)
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
                //case .success(let tempArray):
                case .success(let tempTuple):
                    self.tracks = tempTuple.0
                    //print(tempTuple.1)
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
                case .success(let tempTuple):
                    self.tracks.append(contentsOf: tempTuple.0)
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
    var isAnimatingStoped = false
    
    func playTrack(indexPath: IndexPath) {
        // play music
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
            guard let duration = allTracksInTable[indexPath.section][indexPath.row].duration else {
                print("NONE DURATION")
                return
            }
            playingView.startAnimating()
            // если нажал на новую ячейку
            // принудительно уберем подсветку ячейки
            
            if let tempIndexPath = tempIndexPath {
                let cell = tableView.cellForRow(at: tempIndexPath)
                cell?.contentView.backgroundColor = .clear
            }
            playingView.alpha = 1

            preloadMusicData(urlString: allTracksInTable[indexPath.section][indexPath.row].previewUrl ?? "None")
            //show playing view
            playingView.player = player
            playingView.playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            playingView.authorNameLabel.text = allTracksInTable[indexPath.section][indexPath.row].authorName
            playingView.trackNameLabel.text = allTracksInTable[indexPath.section][indexPath.row].trackName
            playingView.endTimeValueLabel.text = allTracksInTable[indexPath.section][indexPath.row].durationInString
            playingView.beginTimeValueLabel.text = "0:00"

            // наблюдатель для работы со слайдером прокрутки трека
            if let pto = playingTrackObserver {
                player.removeTimeObserver(pto)
                playingTrackObserver = nil
            }
    
            playingTrackObserver = player.addProgressObserver(action: { (progress) in
                //print(state)
                //print("\(progress) : \(state)")
                if progress > 0, !self.isAnimatingStoped {
                    self.playingView.stopAnimating()
                    self.isAnimatingStoped = true
                    print("STOPPED")
                } // слабый момент, выполняется каждую секунду проигрывания
                self.playingView.durationSlider.value = Float(progress * duration)
                self.playingView.beginTimeValueLabel.text = self.playingView.durationSlider.value.floatToTime()
            })

            playingView.durationSlider.maximumValue = Float(duration)
            playingView.durationSlider.value = 0

            player.play()
            tempIndexPath = indexPath
        }
    }
    
    // MARK: Filtering
    
    @IBAction func filterButtonTap(_ sender: UIButton) {
        // пока так выключаем воспроизведение
        methodForDisappear()
        
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
            searchViewController.modalPresentationStyle = .fullScreen
            present(searchViewController, animated: true, completion: nil)
        }
    }
    
    // MARK: - Reload Data
    @IBAction func reloadDataTap(_ sender: UIButton) {
        loadHotTracks()
        loadData()
    }
    
    // MARK: - Variable for hotTracksContextMenu
    var hotTrackIndex = 0
    
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: CollectionView methods
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        isAnimatingStoped = false
        playTrack(indexPath: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hotTracks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TopTrackCell", for: indexPath) as! TopTrackCell
        cell.setCell(row: indexPath.row, track: hotTracks[indexPath.item])
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.tag == 2 {
            let index = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
            hotTracksProtocolDelegate?.setCurrentPage(index: index)
            hotTrackIndex = index
            //hotTracksProtocolDelegate?.setCurrentTrack(track: hotTracks[index])
        }
    }
    
    // MARK: TableView methods
    
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
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return allTracksInTable[section].count
        if section == 0 {
            return 1
        } else {
            return allTracksInTable[section].count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HorizontalScrollCell") as! HorizontalScrollCell
            cell.registerDataSource(dataSource: self)
            cell.registerDelegate(delegate: self)
            cell.collectionView.reloadData()
            // делегат протокола - сама ячейка
            hotTracksProtocolDelegate = cell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell") as! TrackCell
            cell.setCell(currentTrack: allTracksInTable[indexPath.section][indexPath.row])
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // play music
        isAnimatingStoped = false
        playTrack(indexPath: indexPath)
    }
    
    // подгрузка данных при прокрутке в самый низ таблицы
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset < 10.0, scrollView.tag == 1 {
            lazyLoadData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 200
        } else {
            return 70
        }
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard indexPath.section != 0 else {
            return ContextMenuModel.createMenu(currentTrack: hotTracks[hotTrackIndex])
        }
        return ContextMenuModel.createMenu(currentTrack: allTracksInTable[indexPath.section][indexPath.row])
    }
    
}

