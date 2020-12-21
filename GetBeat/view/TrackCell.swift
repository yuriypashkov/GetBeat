
import UIKit

class TrackCell: UITableViewCell, URLSessionDownloadDelegate {
    
    // MARK: Attributes
    var currentDownloadedFileName: String?
    var track: Track?
    //let downloadsModel = DownloadsModel()
    private lazy var session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
    
    // MARK: IB Outlets
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var testLabel: UILabel!
    @IBOutlet weak var cellButton: UIButton!
    
    // MARK: IB Methods
    @IBAction func downloadButtonTap(_ sender: UIButton) {
        if track?.free == "0" {
            print("BUY")
        } else {
            if let urlString = track?.previewUrl, let filename = track?.realName {
                print("DOWNLOAD START")
                currentDownloadedFileName = filename
                do {
                    let documentURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                    let savedFileURL = documentURL.appendingPathComponent(filename + ".mp3")
                    let activityViewController = UIActivityViewController(activityItems: [savedFileURL], applicationActivities: nil)
                    
                    if FileManager().fileExists(atPath: savedFileURL.path) {
                        DispatchQueue.main.async {
                            self.window?.rootViewController?.present(activityViewController, animated: true, completion: nil)
                        }
                    } else {
                        // запускаем эту историю после проверки, не скачан ли файл до этого
                        testLabel.alpha = 1
                        if let url = URL(string: urlString) {
                            let downloadTask = session.downloadTask(with: url)
                            downloadTask.resume()
                        }
                    }
                } catch {
                    print("ERROR ON STATEMENT")
                }
            }
        }
    }
    
    
    // MARK: Methods
    func setCell(currentTrack: Track) {
        // очень слабый момент парсинга имени автора и названия трека, могут быть косяки
        trackNameLabel.text = currentTrack.trackName
        authorNameLabel.text = currentTrack.authorName
        track = currentTrack
        
        if currentTrack.free == "0" {
            cellButton.setImage(UIImage(named: "cart50px"), for: .normal)
        } else {
            cellButton.setImage(UIImage(named: "download50px"), for: .normal)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            self.coloredCell()
        } else {
            contentView.backgroundColor = .clear
        }
    }
    
    // MARK: URLSessionDownloadDelegate stubs
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        guard let filename = currentDownloadedFileName else { return }
        
        do {
            let documentURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let savedFileURL = documentURL.appendingPathComponent(filename + ".mp3")
            let activityViewController = UIActivityViewController(activityItems: [savedFileURL], applicationActivities: nil)
            try FileManager.default.moveItem(at: location, to: savedFileURL)
            DispatchQueue.main.async {
                self.window?.rootViewController?.present(activityViewController, animated: true, completion: nil)
                self.testLabel.alpha = 0
            }
        } catch {
            print("ERROR IN FILEURL")
        }
        
        print("DOWNLOAD COMPLETE")
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let percentDownloaded = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        DispatchQueue.main.async {
            let value = percentDownloaded * 100
            self.testLabel.text = "\(value.rounded())%"
        }
    }
    
}
