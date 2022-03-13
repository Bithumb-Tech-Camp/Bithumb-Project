//
//  DataRepositoryProtocol.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/03/12.
//

import Foundation

protocol DataRepositoryProtocol {
    associatedtype KEY
    associatedtype VALUE
    static func save(_ value: VALUE, key: KEY)
    static func fetch(_ key: KEY) -> [VALUE]
    static func delete(_ key: KEY)
}
