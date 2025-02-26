//
//  Endpoint.swift
//  RNetworkKit
//
//  Created by RAJEEV MAHAJAN on 26/02/25.
//

import Foundation

public protocol EndPoint {
    var baseUrl: String { get }
    var scheme: String { get }
    var path: String { get }
    var method: RequestMethod { get }
    var headers: [String: String]?{ get }
    var bodyParams: [String: String]? { get }
    var queryParams: [String: String]? { get }
}

public enum RequestMethod: String {
    case get = "GET"
    case post = "POST"
}

