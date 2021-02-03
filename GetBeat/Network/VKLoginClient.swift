

import Foundation
import WebKit
import UIKit

protocol VKLoginProtocol {
    func setupAfterLogin(state: Bool, user: User, username: String, password: String, isEmailLogin: Bool)
    func setupElements(state: Bool)
    //func printAny(text: String)
}

class VKLoginClient: NSObject, WKNavigationDelegate {
    
    var delegate: VKLoginProtocol?
    
    // MARK: Attributes
    var token: String?
    var userVKid: String?
    //var user: User?
    let controller = UIViewController()
    let activityIndicator = UIActivityIndicatorView()
    let defaults = UserDefaults.standard
    
    var webView: WKWebView = {
                let web = WKWebView.init(frame: UIScreen.main.bounds)
                return web
            }()
    
    // MARK: Init
    override init() {
        super.init()
        webView.navigationDelegate = self
    }
    
    // MARK: Methods

    func getUserFromGetBeat(onResult: @escaping (Result<User, Error>) -> Void) {
        //let backgroundQueue = DispatchQueue.global(qos: .background) 
    }
    
    func showPermissions() {
        let urlString = "https://oauth.vk.com/authorize?client_id=5934678&display=page&redirect_uri=https://oauth.vk.com/blank.html&scope=offline&response_type=token&v=5.126"
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        webView.load(request)
        controller.view.addSubview(webView)
        UIApplication.shared.windows.first?.rootViewController?.present(controller, animated: true, completion: nil)

    }
    
    func setWebViewControllerAfterLoadingToken() {
        let tempView = UIView(frame: UIScreen.main.bounds)
        tempView.backgroundColor = .white
        controller.view.addSubview(tempView)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let url = webView.url {
            print("WE HAVE URL")
            let string = url.description
            if string.contains("access_token=") {

                // set VC
                setWebViewControllerAfterLoadingToken()
                
                print("WE HAVE A TOKEN")
                let array = string.components(separatedBy: "access_token=")
                let secondArray = array[1].components(separatedBy: "&")
                token = secondArray[0]
                
                // save token to defaults
                defaults.setValue(token, forKey: "vkToken")
                
                if let idElement = secondArray.last {
                    userVKid = idElement.components(separatedBy: "=")[1]
                    // save VK id in defaults
                    defaults.setValue(userVKid, forKey: "userVKid")
                    // отправляем данные в ВК
                    getDataFromVK { (result) in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let tempUser):
                                //self.user = tempUser
                                self.controller.dismiss(animated: true, completion: nil)
                                self.delegate?.setupElements(state: true)
                                self.getDataFromGetBeat(user: tempUser)
                                
                            case .failure(let error):
                                //self.user = nil
                            print(error)
                            }
                        }
                    }
                }
            } else {
                print("Error with token")
            }
        }
    }
    
    func getDataFromVK(onResult: @escaping (Result<User, Error>) -> Void) {
        guard let userID = userVKid, let token = token else {return}
        let urlString = "https://api.vk.com/method/users.get?user_ids=\(userID)&fields=bdate,photo_200,photo_rec&access_token=\(token)&v=5.126"
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            do {
                guard let data = data else {
                    onResult(.failure(NetworkError.noData))
                    return
                }
                let res = try JSONDecoder().decode(Response.self, from: data)
                onResult(.success(res.response[0]))
            }
            catch {
                onResult(.failure(error))
            }
        }
        dataTask.resume()
    }
    
    func getDataFromGetBeat(user: User) {
        //guard let user = user else { return }
        
        let urlString = "https://getbeat.ru/lib/login.php"
        let url = URL(string: urlString)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"

        if let id = userVKid, let firstname = user.firstName, let lastname = user.lastName, let photoRec = user.photo {
            let hash = "5934678\(id)kuafDWBZZArFO5zBvZfL"
            //print(hash)
            //print(hash.md5Value)
            let queryItems: [URLQueryItem] = [
                URLQueryItem(name: "uid", value: id),
                URLQueryItem(name: "first_name", value: firstname),
                URLQueryItem(name: "last_name", value: lastname),
                URLQueryItem(name: "photo_rec", value: photoRec),
                URLQueryItem(name: "hash", value: hash.md5Value)
            ]
            
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            components.queryItems = queryItems
            let query = components.url!.query
            urlRequest.httpBody = Data(query!.utf8)
            
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                DispatchQueue.main.async {
                    guard let data = data else {return}
                    do {
                        let getBeatResponse = try JSONDecoder().decode(User.self, from: data)
                        // надо передать getBeatResponse в LoginViewController
                        //print(getBeatResponse)
                        //print("VKID = \(getBeatResponse.vkid), firstname = \(getBeatResponse.firstName)")
                        self.delegate?.setupAfterLogin(state: true, user: getBeatResponse, username: "nil", password: "nil", isEmailLogin: false)
                        
                    } catch {
                        print(error)
                    }
                }

            }
            dataTask.resume()
        }
    }
    
    
}
