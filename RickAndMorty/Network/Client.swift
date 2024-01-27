//
//  Client.swift
//  RickAndMorty
//
//  Created by Diplomado on 02/12/23.
//

import Foundation

struct Client {
    let session = URLSession.shared
    let baseURL: String
    private let contentType: String
    
    enum NetworkErrors: Error {
        case conection
        case client
        case invalidRequest
        case server
    }
    
    init(_ baseUrl: String, contentType: String = "application/json") {
        self.baseURL = baseUrl
        self.contentType = contentType
    }
    
    typealias requesHandler = ((Data?) -> Void)
    typealias errorHandler = ((Error) -> Void)
    
    func get(_ path: String, success: requesHandler?, failure: errorHandler? = nil) {
        request(method: "GET", path: path, body: nil, success: success, failure: failure)
    }
    
    func request(method: String, path: String, body: Data?, success: requesHandler?, failure: errorHandler? = nil) {
        guard let request = buildRequest(method: method, path: path, body: body) else {
            failure?(NetworkErrors.invalidRequest)
            return
        }
        
        let task = session.dataTask(with: request) { data, response, error in
            if let err = error {
                #if DEBUG
                debugPrint(err)
                #endif
                failure?(NetworkErrors.conection)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                failure?(NetworkErrors.invalidRequest)
                return
            }
    
            
            let status = StatusCode(rawValue: httpResponse.statusCode)
            #if DEBUG
            print("Status: \(httpResponse.statusCode)")
            debugPrint(httpResponse)
            #endif
            
            switch status {
            case .sucess:
                success?(data)
            case .clientError:
                failure?(NetworkErrors.client)
            case .serverError:
                failure?(NetworkErrors.server)
            default:
                failure?(NetworkErrors.invalidRequest)
            }
        }
        task.resume()
    }
    
    func buildRequest(method: String, path: String, body: Data?) -> URLRequest? {
        guard var urlComp = URLComponents(string: baseURL) else { return nil }
        urlComp.path = path
        
        guard let url = urlComp.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        #if DEBUG
        debugPrint(request)
        #endif
        
        return request
    }
}
