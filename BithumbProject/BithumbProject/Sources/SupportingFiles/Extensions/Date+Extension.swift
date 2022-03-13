//
//  Date+Extenstion.swift
//  BithumbProject
//
//  Created by Haeseok Lee on 2022/03/12.
//

import Foundation

extension Date {
    
    var hour: Int { Calendar.current.component(.hour, from: self) }
    
    var minute: Int { Calendar.current.component(.minute, from: self) }
    
    var timeIntervalSince1970ms: Int64 {
        Int64(self.timeIntervalSince1970 * 1000)
    }
    
    var currentHour: Date {
        Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: self)!
    }
    
    var currentMinute: Date {
        Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: self)!
    }

    var yesterday00Hour: Date {
        let date = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self)!
        return hourBefore(date: date, interval: 1, nHour: 24)
    }
    
    var yesterday12Hour: Date {
        let date = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
        return hourBefore(date: date, interval: 1, nHour: 24)
    }
    
    var yesterday18Hour: Date {
        let date = Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: self)!
        return hourBefore(date: date, interval: 1, nHour: 24)
    }
    
    var before1Hour: Date {
        let date = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: self)!
        return hourBefore(date: date, interval: 1, nHour: 1)
    }
    
    var before30Minute: Date {
        let date = Calendar.current.date(bySettingHour: hour, minute: minute >= 30 ? 30 : 00, second: 0, of: self)!
        return minuteBefore(date: date, interval: 1, nMinute: 30)
    }
    
    var before10Minute: Date {
        let minute = (self.minute / 10) * 10
        let date = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: self)!
        return minuteBefore(date: date, interval: 1, nMinute: 10)
    }
    
    var before5Minute: Date {
        let minute = (self.minute / 10) * 10
        let date = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: self)!
        return minuteBefore(date: date, interval: 1, nMinute: 5)
    }
    
    var before3Minute: Date {
        var minute = self.minute
        let (mok, namugi) = (minute / 3, minute % 3)
        if mok > 0 {
            minute = mok * 3
        } else {
            minute = 57
        }
        if namugi == 0 {
            minute -= 3
        }
        
        let date = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: self)!
        return minuteBefore(date: date, interval: 1, nMinute: 3)
    }
    
    var before1Minute: Date {
        let minute = self.minute - 1
        let date = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: self)!
        return minuteBefore(date: date, interval: 1, nMinute: 1)
    }
    
    func beforeMinute(minute: Int) -> Date {
        switch minute {
        case 1:
            return before1Minute
        case 3:
            return before3Minute
        case 5:
            return before5Minute
        case 10:
            return before10Minute
        case 30:
            return before30Minute
        default:
            return before1Minute
        }
    }
    
    func beforeHour(hour: Int) -> Date {
        switch hour {
        case 1:
            return before1Hour
        case 6:
            return yesterday18Hour
        case 12:
            return yesterday12Hour
        case 24:
            return yesterday00Hour
        default:
            return yesterday00Hour
        }
    }
    
    func dayBefore(date: Date, interval: Int, nDay: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: interval * -nDay, to: date)!
    }
    
    func hourBefore(date: Date, interval: Int, nHour: Int) -> Date {
        Calendar.current.date(byAdding: .hour, value: interval * -nHour, to: date)!
    }
    
    func minuteBefore(date: Date, interval: Int, nMinute: Int) -> Date {
        Calendar.current.date(byAdding: .minute, value: interval * -nMinute, to: date)!
    }
    
    func localDate(date: Date) -> Date {
        let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: date))
        guard let localDate = Calendar.current.date(byAdding: .second, value: Int(timeZoneOffset), to: date) else { return Date() }
        return localDate
    }
}
