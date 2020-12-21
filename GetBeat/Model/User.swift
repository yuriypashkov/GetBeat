
import Foundation

struct User: Decodable {
    
    var id: String?
    var firstName: String?
    var lastName: String?
    var photo: String?
    var yamoney: String?
    var login: Bool?
    var nickname: String?
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case first_name
        case last_name
        case photo_rec
        case login
        case nickname
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try? container.decode(String.self, forKey: .id)
        self.firstName = try? container.decode(String.self, forKey: .first_name)
        self.lastName = try? container.decode(String.self, forKey: .last_name)
        self.photo = try? container.decode(String.self, forKey: .photo_rec)
        self.login = try? container.decode(Bool.self, forKey: .login)
        self.nickname = try? container.decode(String.self, forKey: .nickname)
    }
}

//struct AuthError: Decodable {
//    var login: Bool?
//}
