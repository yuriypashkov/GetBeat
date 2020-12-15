

import Foundation
import UIKit
import AVFoundation

class PlayingView: UIView {
    
    var trackNameLabel: UILabel!
    var authorNameLabel: UILabel!
    var playPauseButton: UIButton!
    var player: AVPlayer?
    var durationSlider: UISlider!
    var beginTimeValueLabel: UILabel!
    var endTimeValueLabel: UILabel!
    
    init(position: CGPoint, width: CGFloat, height: CGFloat) {
        super.init(frame: CGRect(x: position.x, y: position.y, width: width, height: height))
        self.backgroundColor = .systemGreen
        
        let swipeDownGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(tapOnView))
        swipeDownGestureRecognizer.direction = .down
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(swipeDownGestureRecognizer)
        
        let swipeUpGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(tapOnView))
        swipeUpGestureRecognizer.direction = .up
        self.addGestureRecognizer(swipeUpGestureRecognizer)
        
        trackNameLabel = UILabel()
        trackNameLabel.translatesAutoresizingMaskIntoConstraints = false
        trackNameLabel.textColor = .white
        trackNameLabel.font = UIFont.boldSystemFont(ofSize: 17)
        trackNameLabel.text = "TrackName"
        self.addSubview(trackNameLabel)
        
        authorNameLabel = UILabel()
        authorNameLabel.translatesAutoresizingMaskIntoConstraints = false
        authorNameLabel.textColor = .systemGray5
        authorNameLabel.font = UIFont.systemFont(ofSize: 15)
        authorNameLabel.text = "Author"
        self.addSubview(authorNameLabel)
        
        playPauseButton = UIButton()
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        playPauseButton.setImage(UIImage(named: "pause60px"), for: .normal)
        self.addSubview(playPauseButton)
        playPauseButton.addTarget(self, action: #selector(tapButton), for: .touchUpInside)
        
        durationSlider = UISlider()
        //durationSlider.thumbTintColor = .black
        durationSlider.translatesAutoresizingMaskIntoConstraints = false
        durationSlider.maximumValue = 30
        durationSlider.minimumValue = 0
        durationSlider.value = 3
        durationSlider.isContinuous = false
        self.addSubview(durationSlider)
        durationSlider.addTarget(self, action: #selector(didSliderChange(_:)), for: .valueChanged)
        
        beginTimeValueLabel = UILabel()
        beginTimeValueLabel.textAlignment = .center
        beginTimeValueLabel.translatesAutoresizingMaskIntoConstraints = false
        beginTimeValueLabel.textColor = .systemGray5
        beginTimeValueLabel.font = UIFont.systemFont(ofSize: 13)
        beginTimeValueLabel.text = "0:00"
        //beginTimeValueLabel.backgroundColor = .red
        self.addSubview(beginTimeValueLabel)
        
        endTimeValueLabel = UILabel()
        endTimeValueLabel.textAlignment = .center
        endTimeValueLabel.translatesAutoresizingMaskIntoConstraints = false
        endTimeValueLabel.textColor = .systemGray5
        endTimeValueLabel.font = UIFont.systemFont(ofSize: 13)
        endTimeValueLabel.text = "0:00"
        self.addSubview(endTimeValueLabel)
        
        let constraints = [
            trackNameLabel.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 16),
            trackNameLabel.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            trackNameLabel.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -56),
            authorNameLabel.topAnchor.constraint(equalTo: trackNameLabel.safeAreaLayoutGuide.bottomAnchor, constant: 8),
            authorNameLabel.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            authorNameLabel.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -56),
            playPauseButton.widthAnchor.constraint(equalToConstant: 30),
            playPauseButton.heightAnchor.constraint(equalToConstant: 30),
            playPauseButton.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            playPauseButton.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 16),
            durationSlider.topAnchor.constraint(equalTo: authorNameLabel.safeAreaLayoutGuide.bottomAnchor, constant: 32),
            durationSlider.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 56),
            durationSlider.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -56),
            beginTimeValueLabel.topAnchor.constraint(equalTo: authorNameLabel.safeAreaLayoutGuide.bottomAnchor, constant: 38),
            beginTimeValueLabel.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            beginTimeValueLabel.trailingAnchor.constraint(equalTo: durationSlider.safeAreaLayoutGuide.leadingAnchor, constant: -8),
            endTimeValueLabel.topAnchor.constraint(equalTo: authorNameLabel.safeAreaLayoutGuide.bottomAnchor, constant: 38),
            endTimeValueLabel.leadingAnchor.constraint(equalTo: durationSlider.safeAreaLayoutGuide.trailingAnchor, constant: 8),
            endTimeValueLabel.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -8)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc func didSliderChange(_ sender: UISlider) {
        if let player = player {
            player.seek(to: CMTimeMakeWithSeconds(Float64(sender.value), preferredTimescale: 1))
        }
    }
    
    var isOpened = false
    
    @objc func tapOnView() {
        if isOpened {
            UIView.animate(withDuration: 0.3) {
                self.frame.origin.y += 90
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.frame.origin.y -= 90
            }
        }
        isOpened = !isOpened
    }
    
    @objc func tapButton() {
        if let player = player {
            if player.timeControlStatus == .playing {
                player.pause()
                playPauseButton.setImage(UIImage(named: "play60px"), for: .normal)
            } else {
                player.play()
                playPauseButton.setImage(UIImage(named: "pause60px"), for: .normal)
            }
        }
    }
    
    func setViewOnDefault() {
        durationSlider.value = 0
        beginTimeValueLabel.text = "0:00"
        playPauseButton.setImage(UIImage(named: "play60px"), for: .normal)
        if let player = player {
            player.seek(to: CMTimeMakeWithSeconds(Float64(0), preferredTimescale: 1))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
