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
    fileprivate func makeRequest(endpoint: EndPoint) -> URLRequest? {
        var urlComponents = URLComponents()
        urlComponents.scheme = endpoint.scheme
        urlComponents.host = endpoint.baseUrl
        urlComponents.path = endpoint.path

        // Set query parameters
        if let queryParams = endpoint.queryParams {
            urlComponents.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        guard let url = urlComponents.url else { return nil }
        var request = URLRequest(url: url)

        // Set headers
        request.allHTTPHeaderFields = endpoint.headers

        // Set HTTP method (GET, POST, etc.)
        request.httpMethod = endpoint.method.rawValue

        // Set body parameters (assuming they are in form of key-value pairs and encoded as JSON)
        if let bodyParams = endpoint.bodyParams {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: bodyParams, options: [])
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                print("Failed to encode body parameters")
                return nil
            }
        }

        return request
    }
}
