//
//  IntOrString.swift
//  BithumbProject
//
//  Created by Haeseok Lee on 2022/03/05.
//

import Foundation

enum IntString: Codable {

    case int(UInt64)
    case string(String)

    init(from decoder: Decoder) throws {

        if let string = try? decoder.singleValueContainer().decode(String.self) {
            self = .string(string)
            return
        }

        if let int = try? decoder.singleValueContainer().decode(UInt64.self) {
            self = .int(int)
            return
        }

        throw IntOrStringError.intOrStringNotFound
    }

    enum IntOrStringError: Error {
        case intOrStringNotFound
    }
}
