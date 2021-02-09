//
//  NetworkModel.swift
//  GetBeat
//
//  Created by Yuriy Pashkov on 12/8/20.
//

import Foundation

enum NetworkError: Error {
    case noData
    case badResponse
}

class NetworkModel {
    
    func getTracks(queryItems: [URLQueryItem], onResult: @escaping (Result<([Track], String?), Error>) -> Void) {
        let session = URLSession.shared
        let url = URL(string: "https://getbeat.ru/lib/catalogSearchengine.php")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = queryItems
        let query = components.url!.query
        urlRequest.httpBody = Data(query!.utf8)
        
        urlRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type") // метод кодирования значений в запросе
        
        let dataTask = session.dataTask(with: urlRequest) { (data, response, error) in
            
            guard let data = data else {
                onResult(.failure(NetworkError.noData))
                return
            }
            
            do {
                let tracksResponse = try JSONDecoder().decode(TracksResponse.self, from: data)
                onResult(.success((tracksResponse.tracks, tracksResponse.countModel.count)))
            }
            catch (let error){
                onResult(.failure(error))
            }
        }
        dataTask.resume()
    }
    
    func getHotTracks(onResult: @escaping (Result<[Track], Error>) -> Void) {
        let session = URLSession.shared
        let url = URL(string: "https://getbeat.ru/lib/spotlight.php")!
        let urlRequest = URLRequest(url: url)
        
        let dataTask = session.dataTask(with: urlRequest) { (data, response, error) in
            guard let data = data else {
                onResult(.failure(NetworkError.noData))
                return
            }
            
            do {
                let tracksResponse = try JSONDecoder().decode([Track].self, from: data)
                onResult(.success(tracksResponse))
            }
            catch (let error) {
                onResult(.failure(error))
            }
            
        }
        dataTask.resume()
    }
    
    func search(queryString: String, onResult: @escaping (Result<[Track], Error>) -> Void) {
        let session = URLSession.shared
        let encodedQuery = queryString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = URL(string: "https://getbeat.ru/lib/search.php?query=\(encodedQuery!)")!
        let urlRequest = URLRequest(url: url)
        
        let dataTask = session.dataTask(with: urlRequest) { (data, response, error) in
            guard let data = data else {
                onResult(.failure(NetworkError.noData))
                return
            }
            
            do {
                let tracksResponse = try JSONDecoder().decode(TracksResponse.self, from: data)
                onResult(.success(tracksResponse.tracks))
            }
            catch (let error) {
                onResult(.failure(error))
            }
        }
        
        dataTask.resume()
    }
    
    func login(queryData: [String: String], onResult: @escaping (Result<VKUser, Error>) -> Void) {
        let session = URLSession.shared
        let url = URL(string: "https://getbeat.ru/lib/loginByEmail.php")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        var queryItems: [URLQueryItem] = []
        for (key, value) in queryData {
            let queryItem = URLQueryItem(name: key, value: value)
            queryItems.append(queryItem)
        }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = queryItems
        let query = components.url!.query
        urlRequest.httpBody = Data(query!.utf8)
        
        urlRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let dataTask = session.dataTask(with: urlRequest) { (data, response, error) in
            
            guard let data = data else {
                onResult(.failure(NetworkError.noData))
                return
            }
            
            guard let _ = response as? HTTPURLResponse else {
                onResult(.failure(NetworkError.badResponse))
                return
            }
            //print(response.statusCode)
            
            do {
                let user = try JSONDecoder().decode(VKUser.self, from: data)
                onResult(.success(user))
            }
            catch (let error) {
                onResult(.failure(error))
            }
 
        }
        dataTask.resume()
    }
    
}
