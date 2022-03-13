//
//  NetworkError.swift
//  BithumbProject
//
//  Created by Haeseok Lee on 2022/02/24.
//

import Foundation

enum NetworkError: Error {
    case jsonError
    case unknown
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .jsonError:
            return "json 에러"
        case .unknown:
            return "unknown 에러"
        }
    }
}
