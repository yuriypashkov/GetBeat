
import Foundation
import AVFoundation

struct Track: Decodable {
    
    var id: String?
    var seoLink: String?
    var idTrack: String?
    var ganre: String?
    var emotion: String?
    var bpm: String?
    var keyTone: String?
    var tags: [String]?
    var price: Price?
    var currency: String?
    var realName: String?
    var free: String?
    var hook: String? // припев Да или Нет
    var duration: Double?
    var priceLicense: String?
    
    var authorName: String {
        if let realName = self.realName {
            let array = realName.components(separatedBy: " - ")
            if array.count >= 2 {
                return array[0] + " "
            } else {
                return "Unknown artist "
            }
        } else {
            return "Unknown artist "
        }
    }
    
    var trackName: String {
        if let realName = self.realName {
            let array = realName.components(separatedBy: "-")
            if array.count >= 2 {
                
                // отсекаем из строки название трека
                var name = ""
                for i in 1..<array.count {
                    name += array[i]
                    if i < array.count - 1 {
                        name += "-"
                    }
                }
                name.remove(at: name.startIndex)
                
                // убираем россию из названия
                if name[name.index(before: name.endIndex)] == ")" {
                    name.remove(at: name.index(before: name.endIndex))
                    if let index = name.lastIndex(of: "(") {
                       name.removeSubrange(index..<name.endIndex)
                    }
                }
                
                return name
            } else {
                return realName
            }
        } else {
            return "Unknown track "
        }
    }
    
    var previewUrl: String? {
        if let idTrack = idTrack {
            return "https://getbeat.ru/Storage/mp3/\(idTrack).mp3"
        } else {
            return nil
        }
    }
    
    
    var durationInString: String? {
        if let duration = duration {
            let minutes = duration / 60
            let seconds = Int(duration.rounded()) % 60
            if seconds < 10 {
                return "\(Int(minutes.rounded(.down))):0\(seconds)"
            } else {
                return "\(Int(minutes.rounded(.down))):\(seconds)"
            }
        }
        return nil
    }

    
}

enum Price: Codable {
    case int(Int)
    case string(String)
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .int(let v): try container.encode(v)
        case .string(let v): try container.encode(v)
        }
    }
    
    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer()
        do {
            self = .int(try value.decode(Int.self))
        } catch DecodingError.typeMismatch {
            self = .string(try value.decode(String.self))
        }
    }

}

// парсим количество получаемых треков, бэк возвращает его в очень странном виде, поэтому так
struct TracksCount: Decodable {
    var count: String?
    
    private enum CodingKeys : String, CodingKey {
        case count = "0"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.count = try? container.decode(String.self, forKey: .count)
    }
    
}

struct TracksResponse: Decodable {
    let tracks: [Track]
    let countModel: TracksCount
    
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        tracks = try container.decode([Track].self)
        countModel = try container.decode(TracksCount.self)
    }
}

struct TrackResponseForSearch: Decodable {
    let tracks: [Track]
    
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        tracks = try container.decode([Track].self)
    }
}
