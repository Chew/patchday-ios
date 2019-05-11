//
//  ExpirationIntervalUD.swift
//  PatchData
//
//  Created by Juliya Smith on 4/28/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class ExpirationIntervalValueHolder: PDValueHolding {
    
    static var tawKey = { return "One half-week" }()
    static var oawKey = { return "One week" } ()
    static var etwKey = { return "Two weeks" }()
    
    public typealias KeyIndex = ExpirationInterval
    
    public typealias RawValue = String
    
    var indexer: ExpirationInterval
    
    required public init(indexer: ExpirationInterval) {
        self.indexer = indexer
    }
    
    public convenience init(raw: String) {
        switch raw {
        case ExpirationIntervalValueHolder.etwKey:
            self.init(indexer: .EveryTwoWeeks)
        case ExpirationIntervalValueHolder.oawKey:
            self.init(indexer: .OnceAWeek)
        default:
            self.init(indexer: .TwiceAWeek)
        }
    }
    
    public var heldValue: String {
        get {
            switch indexer {
            case .TwiceAWeek: return ExpirationIntervalValueHolder.tawKey
            case .OnceAWeek: return ExpirationIntervalValueHolder.oawKey
            case .EveryTwoWeeks: return ExpirationIntervalValueHolder.etwKey
            }
        }
    }
}

// MARK: - Private

public class ExpirationIntervalUD: PDKeyStorable {
    
    private var v: ExpirationInterval
    private var valueHolder: ExpirationIntervalValueHolder
    
    public typealias Value = ExpirationInterval
    public typealias RawValue = String
    
    public var value: ExpirationInterval {
        get { return v }
        set {
            v = newValue
            valueHolder = ExpirationIntervalValueHolder(indexer: v)
        }
    }
    
    public var rawValue: String {
        get { return valueHolder.heldValue }
    }
    
    public static var key = PDDefault.ExpirationInterval
    
    public required init(with val: String) {
        valueHolder = ExpirationIntervalValueHolder(raw: val)
        v = valueHolder.indexer
    }
    
    public required init(with val: ExpirationInterval) {
        v = val
        valueHolder = ExpirationIntervalValueHolder(indexer: v)
    }
    
    public var hours: Int {
        get {
            switch value {
            case .TwiceAWeek:
                return 84
            case .OnceAWeek:
                return 168
            case .EveryTwoWeeks:
                return 336
            }
        }
    }
    
    public var humanPresentableValue: String {
        get { return ExpirationIntervalUD.getHumanPresentableValue(from: rawValue)! }
    }
    
    public static func makeExpirationInterval(from humanReadableStr: String) -> ExpirationInterval? {
        switch humanReadableStr {
        case PDPickerStrings.expirationIntervals[0]:
            return ExpirationInterval.TwiceAWeek
        case PDPickerStrings.expirationIntervals[1]:
            return ExpirationInterval.OnceAWeek
        case PDPickerStrings.expirationIntervals[2]:
            return ExpirationInterval.EveryTwoWeeks
        default:
            return nil
        }
    }
    
    private static func getHumanPresentableValue(from v: String) -> String? {
        let dispStrs = PDPickerStrings.expirationIntervals
        let strDict = [ExpirationIntervalValueHolder.tawKey: dispStrs[0],
                       ExpirationIntervalValueHolder.oawKey : dispStrs[1],
                       ExpirationIntervalValueHolder.etwKey : dispStrs[2]]
        return strDict[v]
    }
}
