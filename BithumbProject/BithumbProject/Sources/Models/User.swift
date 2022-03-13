//
//  User.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/03/13.
//

import Foundation

class User {
    let name: String
    let assets: Double
    
    init(
        name: String,
        assets: Double
    ){
        self.name = name
        self.assets = assets
    }
}
