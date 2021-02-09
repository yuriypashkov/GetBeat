//
//  PurchaseViewController.swift
//  GetBeat
//
//  Created by Yuriy Pashkov on 2/4/21.
//

import UIKit

class PurchaseViewController: UIViewController {
    // MARK: - Attributes
    var purchase: [BuyTrack] = []

    
    // MARK: - IB Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - VC methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

}

extension PurchaseViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return purchase.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PurchaseCell") as! PurchaseCell
        cell.setCell(currentTrack: purchase[indexPath.row])
        return cell
    }
    
    
}
