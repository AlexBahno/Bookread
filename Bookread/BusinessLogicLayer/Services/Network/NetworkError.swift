//
//  NetworkError.swift
//  CityWeather
//
//  Created by Alexandr Bahno on 12.03.2026.
//

import Foundation
import Alamofire

// MARK: - Custom Network Error
enum NetworkError: LocalizedError {
    case network(AFError)
    case parser
    case server(ServerError)
    case unknown
    
    var isNotConnectedToInternet: Bool {
        switch self {
        case .network(let afError):
            switch afError {
            case .sessionTaskFailed(let error):
                return (error as? URLError)?.code == .notConnectedToInternet
            default:
                return false
            }
        case .parser,
                .server,
                .unknown:
            return false
        }
    }
    
    var isCanceled: Bool {
        switch self {
        case .network(let afError):
            switch afError {
            case .sessionTaskFailed(let error):
                return (error as? URLError)?.code == .cancelled
            default:
                return false
            }
        case .parser,
                .server,
                .unknown:
            return false
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .network(let afError):
            return afError.underlyingError?.localizedDescription
        case .parser:
            return "Something went wrong with the parse of the model"
        case .unknown:
            return "Something went wrong with the request"
        case .server(let error):
            return error.errorDescription
        }
    }
}

struct ServerError: LocalizedError {
    let errorDescription: String?
    let statusCode: Int?
}
