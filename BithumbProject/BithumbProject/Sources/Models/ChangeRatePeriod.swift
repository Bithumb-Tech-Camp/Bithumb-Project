//
//  ChangeRatePeriod.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/03/03.
//

import Foundation

enum ChangeRatePeriod: String, CaseIterable {
    case MID = "어제대비"
    case day = "24시간"
    case halfDay = "12시간"
    case hour = "1시간"
    case halfHour = "30분"
}
