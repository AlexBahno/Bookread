//
//  NetworkService.swift
//  CityWeather
//
//  Created by Alexandr Bahno on 12.03.2026.
//

import UIKit
import Alamofire

// MARK: - NetworkProtocol
protocol NetworkProtocol {
    
    func executeWithCodable<Model: Codable>(
        request: IRequest
    ) async throws -> Model
}

final class NetworkService: NetworkProtocol {
    
    func executeWithCodable<Model: Codable>(
        request: IRequest
    ) async throws -> Model {
        let url = URL(string: NetworkConstants.booksBaseUrl + request.path)!
        let method: HTTPMethod = request.method
        let parameters: [String: Any] = request.parameters
        let headers: HTTPHeaders = HTTPHeaders(request.headers)
        
        do {
            return try await AF.request(
                url,
                method: method,
                parameters: parameters,
                headers: headers
            )
            .validate(statusCode: 200...299)
            .serializingDecodable(Model.self)
            .value
        } catch {
            let networkError: NetworkError = self.handleError(from: error, data: nil, statusCode: nil)
            throw networkError
        }
    }
    
    private func handleError(
        from error: Error,
        data: Data?,
        statusCode: Int?
    ) -> NetworkError {
        if let data: Data = data,
           let errorDescription: String = String(data: data, encoding: String.Encoding.utf8) {
            return .server(.init(errorDescription: errorDescription, statusCode: statusCode))
        } else {
            return .network((error as? AFError) ?? AFError.sessionInvalidated(error: error))
        }
    }
}
