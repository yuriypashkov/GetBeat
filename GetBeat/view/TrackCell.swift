//
//  TrackCell.swift
//  GetBeat
//
//  Created by Yuriy Pashkov on 12/8/20.
//

import UIKit

class TrackCell: UITableViewCell {

    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var authorNameLabel: UILabel!
    
    //var currentTrack: Track?
    
    func setCell(currentTrack: Track) {
        //print("SET CELL")
        //trackNameLabel.textColor = .black
        //authorNameLabel.textColor = .darkGray
        
        // очень слабый момент парсинга имени автора и названия трека, могут быть косяки
        trackNameLabel.text = currentTrack.trackName
        authorNameLabel.text = currentTrack.authorName
        //self.currentTrack = currentTrack
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            self.coloredCell()
        } else {
            contentView.backgroundColor = .clear
        }
    }
    
}
