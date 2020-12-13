
import Foundation

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
    
    var authorName: String {
        if let realName = self.realName {
            let array = realName.components(separatedBy: "-")
            if array.count >= 2 {
                return array[0]
            } else {
                return "Unknown"
            }
        } else {
            return "Unknown"
        }
    }
    
    var trackName: String {
        if let realName = self.realName {
            let array = realName.components(separatedBy: "-")
            if array.count >= 2 {
                var name = array[1]
                name.remove(at: name.startIndex)
                return name
            } else {
                return realName
            }
        } else {
            return "Unknown"
        }
    }
    
    var previewUrl: String? {
        if let idTrack = idTrack {
            return "https://getbeat.ru/Storage/mp3/\(idTrack).mp3"
        } else {
            return nil
        }
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

struct TracksResponse: Decodable {
    let tracks: [Track]
    
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        tracks = try container.decode([Track].self)
    }
}