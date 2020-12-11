//
//  Extensions.swift
//  GetBeat
//
//  Created by Yuriy Pashkov on 12/11/20.
//

import Foundation
import UIKit

extension UITableViewCell {
    
    func lightningCell() {
        UIView.animate(withDuration: 0.25) {
            self.contentView.backgroundColor = UIColor(red: 0.49, green: 0.80, blue: 0.56, alpha: 0.20)
        } completion: { _ in
            UIView.animate(withDuration: 0.25) {
                self.contentView.backgroundColor = .clear
            }
        }
    }
    
    func coloredCell() {
        UIView.animate(withDuration: 0.25) {
            self.contentView.backgroundColor = UIColor(red: 0.49, green: 0.80, blue: 0.56, alpha: 0.20)
        }
    }
    
}

