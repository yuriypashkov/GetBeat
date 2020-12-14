

import Foundation
import UIKit
import AVFoundation

class PlayingView: UIView {
    
    var trackNameLabel: UILabel!
    var authorNameLabel: UILabel!
    var playPauseButton: UIButton!
    var player: AVPlayer?
    
    init(position: CGPoint, width: CGFloat, height: CGFloat) {
        super.init(frame: CGRect(x: position.x, y: position.y, width: width, height: height))
        self.backgroundColor = .systemGreen
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOnView))
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(tapGestureRecognizer)
        
        
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
            playPauseButton.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 16)
            
        ]
        NSLayoutConstraint.activate(constraints)
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
