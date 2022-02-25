//
//  APIResponse.swift
//  BithumbProject
//
//  Created by 최다빈 on 2022/02/23.
//

import Foundation

struct HTTPResponse<T: Codable>: Codable {
    var status: String?
    var data: T?
    var message: String?
}

struct WebSocketResponse<T: Codable>: Codable {
    var status: String?
    var type: String?
    var content: T?
    var resmsg: String?
}
