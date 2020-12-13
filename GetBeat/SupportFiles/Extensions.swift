

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

