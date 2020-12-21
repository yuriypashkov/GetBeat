

import Foundation
import UIKit
import AVFoundation

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

extension UITextField {
    func addDoneCancelToolbar(onDone: (target: Any, action: Selector)? = nil, onCancel: (target: Any, action: Selector)? = nil) {
        let onCancel = onCancel ?? (target: self, action: #selector(cancelButtonTapped))
        let onDone = onDone ?? (target: self, action: #selector(doneButtonTapped))

        let toolbar: UIToolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(title: "Cancel", style: .plain, target: onCancel.target, action: onCancel.action),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: onDone.target, action: onDone.action)
        ]
        toolbar.sizeToFit()

        self.inputAccessoryView = toolbar
    }

    // Default actions:
    @objc func doneButtonTapped() { self.resignFirstResponder() }
    @objc func cancelButtonTapped() { self.resignFirstResponder() }
}

extension Float {
    
    func floatToTime() -> String {
        let minutes = self / 60
        let seconds = Int(self.rounded()) % 60
        if seconds < 10 {
            return "\(Int(minutes.rounded(.down))):0\(seconds)"
        } else {
            return "\(Int(minutes.rounded(.down))):\(seconds)"
        }
    }
    
}

extension AVPlayer {
    
    func addProgressObserver(action: @escaping ((Double) -> Void)) -> Any {
        return self.addPeriodicTimeObserver(forInterval: CMTime.init(value: 1, timescale: 1), queue: .main, using: { [weak self] time in
            if let duration = self?.currentItem?.duration {
                let duration = CMTimeGetSeconds(duration), time = CMTimeGetSeconds(time)
                let progress = (time/duration)
                action(progress)
            }
        })
    }
    
}
