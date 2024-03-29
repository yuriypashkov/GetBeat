//
//  HorizontalScrollCell.swift
//  GetBeat
//
//  Created by Yuriy Pashkov on 1/30/21.
//

import UIKit

class HorizontalScrollCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControlView: UIView!
    
    //private var currentTrackInScrollView: Track?
    
    func registerDataSource(dataSource: UICollectionViewDataSource){
        self.collectionView.dataSource = dataSource
    }

    func registerDelegate(delegate: UICollectionViewDelegate) {
        self.collectionView.delegate = delegate
    }
    
}

extension HorizontalScrollCell: HotTracksPageControllerDelegate {

    func setNumberOfPages(numberOfPages: Int) {
        pageControlView.subviews.forEach { $0.removeFromSuperview() }

        var spacing: CGFloat = 0
        for i in 0..<numberOfPages {
            let pageView = UIView(frame: CGRect(x: spacing, y: pageControlView.frame.height / 2, width: 25, height: 4))
            pageView.backgroundColor = (i == 0) ? .systemPink : .systemGray
            pageControlView.addSubview(pageView)
            spacing += 40
        }

    }

    func setCurrentPage(index: Int) {
        for i in 0..<pageControlView.subviews.count {
            pageControlView.subviews[i].backgroundColor = (index == i) ? .systemPink : .systemGray
        }
    }

}
