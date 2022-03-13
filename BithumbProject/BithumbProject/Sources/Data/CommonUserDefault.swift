//
//  CommonUserDefault.swift
//  BithumbProject
//
//  Created by 박형석 on 2022/03/12.
//

import Foundation

struct CommonUserDefault<OUTPUT>: DataRepositoryProtocol {
    typealias KEY = DataKey
    typealias VALUE = OUTPUT
    
    enum DataKey: Hashable {
        case username
        case holdings
        case star(String)
        case initialLaunchKey
        case changeRatePeriod
        
        var forKey: String {
            switch self {
            case .username:
                return "username"
            case .holdings:
                return "holdings"
            case .star:
                return "stars"
            case .initialLaunchKey:
                return "initialLaunchKey"
            case .changeRatePeriod:
                return "changeRatePeriod"
            }
        }
    }
    
    /// KEY: DataKey.star
    /// VALUE: coin name
    static func save(_ value: VALUE, key: KEY) {
        var savedData = self.fetch(key)
        savedData += [value]
        UserDefaults.standard.set(savedData, forKey: key.forKey)
    }
    
    static func fetch(_ key: KEY) -> [VALUE] {
        return UserDefaults.standard.array(forKey: key.forKey) as? [VALUE] ?? []
    }
    
    static func delete(_ key: KEY) {
        switch key {
        case .username, .initialLaunchKey, .holdings, .changeRatePeriod:
            UserDefaults.standard.set(nil, forKey: key.forKey)
            UserDefaults.standard.removeObject(forKey: key.forKey)
        case .star(let coinName):
            var stars = self.fetch(.star(coinName)) as? [String] ?? []
            if let index = stars.firstIndex(where: { $0 == coinName }) {
                stars.remove(at: index)
                UserDefaults.standard.set(nil, forKey: key.forKey)
                UserDefaults.standard.removeObject(forKey: key.forKey)
                for star in stars {
                    if let star = star as? OUTPUT {
                        self.save(star, key: .star(coinName))
                    }
                }
            }
        }
    }
    
    // Utility
    static func initialSetting(_ defaultValues: [DataKey: OUTPUT]) {
        if !UserDefaults.standard.bool(forKey: DataKey.initialLaunchKey.forKey) {
            self.defaultSetting(defaultValues)
            UserDefaults.standard.set(true, forKey: DataKey.initialLaunchKey.forKey)
            print("👏🏻 sucess setting initial information 👏🏻")
        }
    }
    
    private static func defaultSetting(_ value: [DataKey: OUTPUT]) {
        for (aKey, avalue) in value {
            self.save(avalue, key: aKey)
        }
    }
    
    static func deRepresentation(with keys: [String]) {
        print(UserDefaults.standard.dictionaryWithValues(forKeys: keys))
    }
}
