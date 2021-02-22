//
//  TabBarController.swift
//  GetBeat
//
//  Created by Yuriy Pashkov on 2/20/21.
//

import UIKit
import AVFoundation

class CustomTabBarController: UITabBarController {
    
    // MARK: - Properties
    var trackNameLabel: UILabel!
    var authorNameLabel: UILabel!
    var playPauseButton: UIButton!
    var player = AVPlayer()
    var playerItem: AVPlayerItem?
    var durationSlider: UISlider!
    var beginTimeValueLabel: UILabel!
    var endTimeValueLabel: UILabel!
    var containerView = UIView()
    var sliderView = UIView()
    private var playingTrackObserver: Any?
    var isAnimatingStoped = false
    
    var activityIndicator = UIActivityIndicatorView()
    
    private enum FontType: String {
        case regular = "Roboto-Regular"
        case bold = "Roboto-Bold"
        case medium = "Roboto-Medium"
    }
    
    // MARK: - VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(didFinishPlayTrack(sender:)), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Other methods
    
    @objc func didFinishPlayTrack(sender: Notification) {
        setViewOnDefault()
    }

    private func createLabel(textColor: UIColor, fontType: FontType, fontSize: CGFloat, textAlignment: NSTextAlignment, text: String) -> UILabel {
        let label = UILabel()
        label.textAlignment = textAlignment
        label.text = text
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = textColor
        label.font = UIFont(name: fontType.rawValue, size: fontSize)
        label.text = text
        return label
    }

    private func configure() {
        
        // add main container
        containerView.backgroundColor = UIColor(red: 0.11, green: 0.11, blue: 0.11, alpha: 0.99)
        containerView.translatesAutoresizingMaskIntoConstraints = true
        containerView.alpha = 0
        let tabBarHeight = tabBar.frame.size.height
        var bottomInset = view.frame.size.height - tabBarHeight - 64
        if let window = UIApplication.shared.windows.first {
            bottomInset -= window.safeAreaInsets.bottom
        }
        containerView.frame = CGRect(x: 0, y: bottomInset, width: view.frame.width, height: 64)
        view.addSubview(containerView)

        // add slider container
        sliderView.backgroundColor = UIColor(red: 0.11, green: 0.11, blue: 0.11, alpha: 0.99)
        sliderView.alpha = 0
        sliderView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sliderView)
        
        let swipeDownGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(tapOnView))
        swipeDownGestureRecognizer.direction = .down
        containerView.isUserInteractionEnabled = true
        containerView.addGestureRecognizer(swipeDownGestureRecognizer)
        
        let swipeUpGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(tapOnView))
        swipeUpGestureRecognizer.direction = .up
        containerView.addGestureRecognizer(swipeUpGestureRecognizer)
        
        trackNameLabel = createLabel(textColor: .white, fontType: .bold, fontSize: 16, textAlignment: .left, text: "trackName")
        containerView.addSubview(trackNameLabel)
 
        authorNameLabel = createLabel(textColor: .systemGray5, fontType: .medium, fontSize: 14, textAlignment: .left, text: "authorName")
        containerView.addSubview(authorNameLabel)
        
        playPauseButton = UIButton()
        playPauseButton.backgroundColor = .label
        playPauseButton.layer.cornerRadius = 20
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playPauseButton.tintColor = .white
        containerView.addSubview(playPauseButton)
        playPauseButton.addTarget(self, action: #selector(tapButton), for: .touchUpInside)
        
        durationSlider = UISlider()
        durationSlider.tintColor = .white
        durationSlider.translatesAutoresizingMaskIntoConstraints = false
        durationSlider.maximumValue = 30
        durationSlider.minimumValue = 0
        durationSlider.value = 3
        durationSlider.isContinuous = false
        sliderView.addSubview(durationSlider)
        durationSlider.addTarget(self, action: #selector(didSliderChange(_:)), for: .valueChanged)
        
        beginTimeValueLabel = createLabel(textColor: .systemGray5, fontType: .regular, fontSize: 13, textAlignment: .center, text: "0:00")
        sliderView.addSubview(beginTimeValueLabel)
        
        endTimeValueLabel = createLabel(textColor: .systemGray5, fontType: .regular, fontSize: 13, textAlignment: .center, text: "0:00")
        sliderView.addSubview(endTimeValueLabel)
        
        //set activity indicator
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .white
        activityIndicator.center = CGPoint(x: view.frame.width - 36, y: 32)
        containerView.addSubview(activityIndicator)
        
        
        let g = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            sliderView.leadingAnchor.constraint(equalTo: g.leadingAnchor),
            sliderView.trailingAnchor.constraint(equalTo: g.trailingAnchor),
            sliderView.bottomAnchor.constraint(equalTo: tabBar.topAnchor, constant: 0),
            sliderView.heightAnchor.constraint(equalToConstant: 64),
            trackNameLabel.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor, constant: 10),
            trackNameLabel.leadingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            trackNameLabel.trailingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.trailingAnchor, constant: -56),
            authorNameLabel.topAnchor.constraint(equalTo: trackNameLabel.safeAreaLayoutGuide.bottomAnchor, constant: 8),
            authorNameLabel.leadingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            authorNameLabel.trailingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.trailingAnchor, constant: -56),
            playPauseButton.widthAnchor.constraint(equalToConstant: 40),
            playPauseButton.heightAnchor.constraint(equalToConstant: 40),
            playPauseButton.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: -16),
            playPauseButton.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor, constant: 12),
            durationSlider.topAnchor.constraint(equalTo: sliderView.safeAreaLayoutGuide.topAnchor, constant: 16),
            durationSlider.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: 56),
            durationSlider.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: -56),
            beginTimeValueLabel.topAnchor.constraint(equalTo: sliderView.safeAreaLayoutGuide.topAnchor, constant: 22),
            beginTimeValueLabel.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: 8),
            beginTimeValueLabel.trailingAnchor.constraint(equalTo: durationSlider.safeAreaLayoutGuide.leadingAnchor, constant: -8),
            endTimeValueLabel.topAnchor.constraint(equalTo: sliderView.safeAreaLayoutGuide.topAnchor, constant: 22),
            endTimeValueLabel.leadingAnchor.constraint(equalTo: durationSlider.safeAreaLayoutGuide.trailingAnchor, constant: 8),
            endTimeValueLabel.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: -8)
        ])
    }
    
    var isOpened = false
    
    @objc func tapOnView() {
        if isOpened {
            UIView.animate(withDuration: 0.3) {
                self.containerView.frame.origin.y += 64
                self.sliderView.alpha = 0
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.containerView.frame.origin.y -= 64
                self.sliderView.alpha = 1
            }
        }
        isOpened = !isOpened
    }
    
    @objc func tapButton() {
            if player.timeControlStatus == .playing {
                player.pause()
                playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            } else {
                player.play()
                playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            }
    }
    
    @objc func didSliderChange(_ sender: UISlider) {
        player.seek(to: CMTimeMakeWithSeconds(Float64(sender.value), preferredTimescale: 1))
    }
    
    func startAnimating() {
        activityIndicator.startAnimating()
        playPauseButton.alpha = 0
    }
    
    func stopAnimating() {
        activityIndicator.stopAnimating()
        playPauseButton.alpha = 1
    }
    
    func setViewOnDefault() {
        durationSlider.value = 0
        beginTimeValueLabel.text = "0:00"
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        player.seek(to: CMTimeMakeWithSeconds(Float64(0), preferredTimescale: 1))
    }
    
    func setPlayingView(currentTrack: Track) {
        authorNameLabel.text = currentTrack.authorName
        trackNameLabel.text = currentTrack.trackName
        beginTimeValueLabel.text = "0:00"
        endTimeValueLabel.text = currentTrack.durationInString
        durationSlider.value = 0
        durationSlider.maximumValue = Float(currentTrack.duration ?? 1)
        playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
    }
    
    func preloadMusicData(urlString: String) {
        let url = URL(string: urlString)
        let playerItem = AVPlayerItem(url: url!)
        player.replaceCurrentItem(with: playerItem)
    }
    
    func createDurationObserver(currentTrack: Track) {
        guard let duration = currentTrack.duration else {
            print("NONE DURATION")
            return
        }
        
        removeDurationObserver()
        
        playingTrackObserver = player.addProgressObserver(action: { (progress) in
            if progress > 0, !self.isAnimatingStoped {
                self.stopAnimating()
                self.isAnimatingStoped = true
                print("STOPPED")
           }
            self.durationSlider.value = Float(progress * duration)
            self.beginTimeValueLabel.text = self.durationSlider.value.floatToTime()
        })
    }
    
    func removeDurationObserver() {
        if let pto = playingTrackObserver {
            player.removeTimeObserver(pto)
            playingTrackObserver = nil
        }
    }
}
