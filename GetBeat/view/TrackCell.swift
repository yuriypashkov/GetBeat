
import UIKit
//import WebKit
import SafariServices

class TrackCell: UITableViewCell, URLSessionDownloadDelegate {
    
    // MARK: Attributes
    let shapeLayer = CAShapeLayer()
    let trackLayer = CAShapeLayer()
    var currentDownloadedFileName: String?
    var track: Track?
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
            guard let url = URL(string: "https://getbeat.ru/order") else { return }
            let svc = SFSafariViewController(url: url)
            window?.rootViewController?.present(svc, animated: true, completion: nil)
        } else {
            if let urlString = track?.previewUrl, let filename = track?.realName {
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
                        cellButton.alpha = 0
                        createCircular()
                        if let url = URL(string: urlString) {
                            let downloadTask = session.downloadTask(with: url)
                            downloadTask.resume()
                        }
                    }
                } catch {
                    print(error)
                }
            }
        }
    }
    
    
    // MARK: Methods
    func createCircular() {
        let center = cellButton.center
        
        let circularPath = UIBezierPath(arcCenter: center, radius: 15, startAngle: -.pi / 2, endAngle: 2 * .pi, clockwise: true)
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = UIColor.lightGray.cgColor
        trackLayer.lineWidth = 3
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = .round
        contentView.layer.addSublayer(trackLayer)
        
        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = UIColor.systemRed.cgColor
        shapeLayer.lineWidth = 3
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = .round
        shapeLayer.strokeEnd = 0
        contentView.layer.addSublayer(shapeLayer)
    }
    
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
                self.cellButton.alpha = 1
                self.shapeLayer.removeFromSuperlayer()
                self.trackLayer.removeFromSuperlayer()
                self.shapeLayer.strokeEnd = 0
            }
        } catch {
            print(error)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let percentDownloaded = CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite)
        DispatchQueue.main.async {
            self.shapeLayer.strokeEnd = percentDownloaded
        }
    }
    
}
