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
    @IBOutlet weak var testLabel: UILabel!
    
    @IBOutlet weak var cellButton: UIButton!
    
    //var currentTrack: Track?
    
    func setCell(currentTrack: Track) {
        //print("SET CELL")
        //trackNameLabel.textColor = .black
        //authorNameLabel.textColor = .darkGray
        
        // очень слабый момент парсинга имени автора и названия трека, могут быть косяки
        trackNameLabel.text = currentTrack.trackName
        authorNameLabel.text = currentTrack.authorName
        //self.currentTrack = currentTrack
       // if let licenseOne = currentTrack.typeLicense {
        if currentTrack.free == "0" {
            cellButton.setImage(UIImage(named: "cart50px"), for: .normal)
        } else {
            cellButton.setImage(UIImage(named: "download50px"), for: .normal)
        }
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
