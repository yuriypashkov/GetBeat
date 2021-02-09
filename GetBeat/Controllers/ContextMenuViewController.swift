//
//  ContextMenuViewController.swift
//  GetBeat
//
//  Created by Yuriy Pashkov on 1/23/21.
//

import UIKit

class ContextMenuViewController: UIViewController {
    
    var currentTrack: Track?

    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var toneLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var emotionLabel: UILabel!
    @IBOutlet weak var ganreLabel: UILabel!
    @IBOutlet weak var hookLabel: UILabel!
    
    static func controller(currentTrack: Track) -> ContextMenuViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let controller = storyboard.instantiateViewController(withIdentifier: "ContextMenuViewController") as! ContextMenuViewController
        controller.currentTrack = currentTrack
        controller.preferredContentSize = CGSize(width: controller.view.frame.width, height: 240)
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trackNameLabel.text = currentTrack?.realName
        toneLabel.text = currentTrack?.keyTone
        tempLabel.text = "\(currentTrack?.bpm ?? "0")" + " Bpm"
        emotionLabel.text = currentTrack?.emotion
        ganreLabel.text = currentTrack?.ganre
        hookLabel.text = currentTrack?.hook
        
        // create tags views
        if let tags = currentTrack?.tags {
            var x: CGFloat = 8
            let y: CGFloat = 195
            for tag in tags {
                let textLabel = createLabel(x: x, y: y, tag: tag)
                view.addSubview(textLabel)
                x += textLabel.frame.width + 15
            }
        }
    }
    
    private func createLabel(x: CGFloat, y: CGFloat, tag: String) -> PaddingLabel {
        let textLabel = PaddingLabel()
        textLabel.layer.cornerRadius = 8
        textLabel.clipsToBounds = true
        textLabel.frame.origin.x = x
        textLabel.frame.origin.y = y
        textLabel.textInsets = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
        textLabel.backgroundColor = .systemRed
        textLabel.textAlignment = .center
        textLabel.font = UIFont(name: "Roboto-Bold", size: 14)
        textLabel.textColor = .white
        textLabel.text = tag
        textLabel.sizeToFit()
        return textLabel
    }

}
