//
//  PurchaseCell.swift
//  GetBeat
//
//  Created by Yuriy Pashkov on 2/4/21.
//

import UIKit

class PurchaseCell: UITableViewCell {
    
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var licenseLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    func setCell(currentTrack: BuyTrack) {
        trackNameLabel.text = currentTrack.name
        if let price = currentTrack.price {
            priceLabel.text = "\(price)₽"
        }
        statusLabel.text = "Unknown"
        switch currentTrack.typeLicense {
        case "0":
            licenseLabel.text = "Лизинг"
        case "1":
            licenseLabel.text = "Эксклюзив"
        default:
            licenseLabel.text = "Unknown"
        }
        dateLabel.text = currentTrack.date
    }
    
    
}
