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
    @IBOutlet weak var buttonBuy: UIButton!
    
    
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
        if let price = track.priceLicense {
            buttonBuy.setTitle("КУПИТЬ ОТ \(price)₽", for: .normal)
        }
        
        // add genre
        if let genre = track.ganre {
            //let x: CGFloat = 8
            //let y: CGFloat = 88
            let textLabel = createLabel(x: 8, y: 84, tag: genre)
            contentView.addSubview(textLabel)
        }
//        if let tags = track.tags {
//            var x: CGFloat = 8
//            let y: CGFloat = 88
//            for tag in tags {
//                let textLabel = createLabel(x: x, y: y, tag: tag)
//                contentView.addSubview(textLabel)
//                x += textLabel.frame.width + 15
//            }
//        }
    }
    
    private func createLabel(x: CGFloat, y: CGFloat, tag: String) -> PaddingLabel {
        let textLabel = PaddingLabel()
        //textLabel.layer.cornerRadius = 8
        //textLabel.clipsToBounds = true
        textLabel.frame.origin.x = x
        textLabel.frame.origin.y = y
        textLabel.textInsets = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
        textLabel.backgroundColor = .systemOrange
        textLabel.textAlignment = .center
        textLabel.font = UIFont(name: "Roboto-Bold", size: 16)
        textLabel.textColor = .white
        textLabel.text = tag
        textLabel.sizeToFit()
        return textLabel
    }
    
}
