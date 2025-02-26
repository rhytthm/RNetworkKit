//
//  Networkable.swift
//  RNetworkKit
//
//  Created by RAJEEV MAHAJAN on 26/02/25.
//

import Foundation
import Combine

public protocol Networkable {
//    func sendRequest<T: Decodable>(endpoint: EndPoint) async throws -> T
    func sendRequest<T: Decodable>(endpoint: EndPoint, resultHandler: @Sendable @escaping (Result<T,Error>) -> Void)
}

public final class NetworkManager: Networkable {
    public init() {}
    public func sendRequest<T>(endpoint: EndPoint, resultHandler: @Sendable @escaping (Result<T, any Error>) -> Void) where T : Decodable {
        guard let urlRequest = makeRequest(endpoint: endpoint ) else { return }
        let urlTask = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard error == nil else { return }
            guard let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode else { return }
            guard let data = data else { return }
            guard let decodedResponse = try? JSONDecoder().decode(T.self, from: data) else { return }
            resultHandler(.success(decodedResponse))
        }
        urlTask.resume()
    }
}

extension Networkable {
    fileprivate func makeRequest(endpoint:EndPoint) -> URLRequest? {
        var urlComponents = URLComponents()
        urlComponents.scheme = endpoint.scheme
        urlComponents.host = endpoint.baseUrl
        urlComponents.path = endpoint.path
        guard let url = urlComponents.url else { return nil }
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = endpoint.headers
        request.httpMethod = endpoint.method.rawValue
        return request
    }
}
