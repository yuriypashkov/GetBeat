
import Foundation

struct User: Decodable {
    
    var id: String?
    var vkid: String?
    var firstName: String?
    var lastName: String?
    var photo: String?
    var photoRec: String?
    var login: Bool?
    var nickname: String?
    var hash: String?
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case vkid
        case first_name
        case last_name
        case photo
        case photo_rec
        case login
        case nickname
        case hash
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try? container.decode(String.self, forKey: .id)
        self.vkid = try? container.decode(String.self, forKey: .vkid)
        self.firstName = try? container.decode(String.self, forKey: .first_name)
        self.lastName = try? container.decode(String.self, forKey: .last_name)
        self.photo = try? container.decode(String.self, forKey: .photo_rec)
        self.login = try? container.decode(Bool.self, forKey: .login)
        self.nickname = try? container.decode(String.self, forKey: .nickname)
        self.photoRec = try? container.decode(String.self, forKey: .photo_rec)
        self.hash = try? container.decode(String.self, forKey: .hash)
    }
}

struct Response: Decodable {
    var response: [User]
}
