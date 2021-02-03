//
//  TopTrackCell.swift
//  GetBeat
//
//  Created by Yuriy Pashkov on 1/30/21.
//
import SafariServices
import UIKit

class TopTrackCell: UICollectionViewCell {
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    
    override func prepareForReuse() {
            super.prepareForReuse()
            //  здесь надо обнулить данные, которые грузятся из сети, дабы корректно работало переиспользование
        }
    
    @IBAction func buyButtonTap(_ sender: UIButton) {
        guard let url = URL(string: "https://getbeat.ru/order") else { return }
        let svc = SFSafariViewController(url: url)
        window?.rootViewController?.present(svc, animated: true, completion: nil)
    }
    
    
    let images = [
            UIImage(named: "1"),
            UIImage(named: "2"),
            UIImage(named: "3")
        ]
    
    func setCell(row: Int, track: Track) {
            backgroundImage.image = images[row]
            trackNameLabel.text = track.trackName
            authorLabel.text = track.authorName
        }
    
}
