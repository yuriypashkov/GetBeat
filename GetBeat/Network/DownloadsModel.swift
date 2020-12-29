//
//import Foundation
//import UIKit
//
//class DownloadsModel {
//
//    func downloadTrack(urlString: String, filename: String, onResult: @escaping (Result<URL, Error>) -> Void) {
//        let session = URLSession.shared
//        let url = URL(string: urlString)!
//        do {
//            let documentURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
//            let savedFileURL = documentURL.appendingPathComponent(filename+".mp3")
//
//            if FileManager().fileExists(atPath: savedFileURL.path) {
//                onResult(.success(savedFileURL))
//            } else {
//                let downloadTask = session.downloadTask(with: url) { (downloadURL, responseURL, error) in
//                    guard let tempFileURL = downloadURL else { return}
//                    do {
//                        try FileManager.default.moveItem(at: tempFileURL, to: savedFileURL)
//                        onResult(.success(savedFileURL))
//                    } catch {
//                        onResult(.failure(error))
//                    }
//                }
//                downloadTask.resume()
//            }
//        } catch {
//            onResult(.failure(error))
//        }
//    }
//
//    func prepareDownload(filename: String) -> URL? {
//        do {
//                let documentURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
//                let savedFileURL = documentURL.appendingPathComponent(filename + ".mp3")
//                if FileManager().fileExists(atPath: savedFileURL.path) {
//                    return savedFileURL
//                } else {
//                    return nil
//                }
//            } catch {
//                print(error)
//            }
//        return nil
//    }
//
//
//}
