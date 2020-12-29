

import UIKit

class SettingsViewController: UIViewController {
    // MARK: Variables and Constants
    var cacheSize: Float = 0
    
    // MARK: IBOutlets
    @IBOutlet weak var clearCacheLabel: UILabel!
    
    
    // MARK: IB Methods
    @IBAction func feedBackTap(_ sender: UIButton) {
        if let url = URL(string: "https://vk.com/get_beat"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    
    @IBAction func clearCacheTap(_ sender: UIButton) {
        deleteFilesFromCache()
        calculateCachSize()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        calculateCachSize()
    }
    
    // MARK: Methods
    func calculateCachSize() {
        cacheSize = 0
        do {
            let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            for fileURL in fileURLs {
                let attribute = try FileManager.default.attributesOfItem(atPath: fileURL.path)
                let fileSizeInBytes = attribute[FileAttributeKey.size] as! Int64
                let fileSizeInMbytes = Float(fileSizeInBytes) / (1024 * 1024)
                cacheSize += fileSizeInMbytes
                print(round(fileSizeInMbytes*100)/100)
            }
            clearCacheLabel.text = "Размер кэша \(round(cacheSize*100)/100) Мб"
        } catch {
            print(error)
        }
    }
    
    func deleteFilesFromCache() {
        do {
            let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            for fileURL in fileURLs {
                try FileManager.default.removeItem(atPath: fileURL.path)
            }
        } catch {
            print(error)
        }
    }

}
