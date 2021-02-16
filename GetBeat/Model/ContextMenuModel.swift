//
//  ContextMenuModel.swift
//  GetBeat
//
//  Created by Yuriy Pashkov on 2/3/21.
//

import Foundation
import UIKit

class ContextMenuModel {
    
    static func createMenu(currentTrack: Track) -> UIContextMenuConfiguration {
        
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: { () -> UIViewController? in
            return ContextMenuViewController.controller(currentTrack: currentTrack)
        }) { (actions) -> UIMenu? in
            let actionShare = UIAction(title: "Поделиться", image: UIImage(systemName: "paperplane")) { (action) in
                if let realName = currentTrack.realName, let seoLink = currentTrack.seoLink {
                    let link = "https://getbeat.ru/beat/" + seoLink
                    let sharingText = "Зацени трек от Getbeat.ru: \(realName). Можно послушать по ссылке: \(link) или скачать мобильное приложение Getbeat в Appstore по ссылке:"
                    let activityViewController = UIActivityViewController(activityItems: [sharingText], applicationActivities: nil)
                    UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
                }
            }
            let actionFavorites = UIAction(title: "В избранное", image: UIImage(systemName: "star")) { (action) in
                if ApplicationAuth.isAuth {
                    print("ADDING")
                } else {
                    print("YOU NEED AUTH")
                }
            }
            return UIMenu.init(title: "", image: nil, identifier: nil, options: .destructive, children: [actionShare, actionFavorites])
        }
        return configuration
        
    }
    
}
