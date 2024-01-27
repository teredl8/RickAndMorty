//
//  RESTClient.swift
//  RickAndMorty
//
//  Created by Tere Durán on 02/12/23.
//

import Foundation

struct RESTClient<T: Codable> {
    let client: Client
    let decoder = JSONDecoder()
    
    init(client: Client) {
        self.client = client
    }
    
    typealias successHandler = ((T) -> Void)
    
    func show(_ path: String, page: Int = 1, success: @escaping successHandler) {
        let fullPath = "\(path)?page=\(page)"
        client.get(fullPath) { data in
            guard let data = data else { return }

            do {
                let json = try decoder.decode(T.self, from: data)
                DispatchQueue.main.async {
                    success(json)
                }
            } catch let err {
                #if DEBUG
                debugPrint(err)
                #endif
            }
        }
    }
}
