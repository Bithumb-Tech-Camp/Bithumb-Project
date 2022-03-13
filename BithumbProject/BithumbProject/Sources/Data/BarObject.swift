//
//  BarObject.swift
//  BithumbProject
//
//  Created by Haeseok Lee on 2022/03/11.
//

import Foundation

import RealmSwift

final class BarObject: Object {
    @Persisted(primaryKey: true) var standardTime: Int64
    @Persisted var volume: Double
}
