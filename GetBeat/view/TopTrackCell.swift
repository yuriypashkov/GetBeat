//
//  TopTrackCell.swift
//  GetBeat
//
//  Created by Yuriy Pashkov on 1/30/21.
//

import UIKit

class TopTrackCell: UICollectionViewCell {
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    
    override func prepareForReuse() {
            super.prepareForReuse()
            //  здесь надо обнулить данные, которые грузятся из сети, дабы корректно работало переиспользование
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
