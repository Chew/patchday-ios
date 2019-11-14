//
//  Hormone.swift
//  PatchData
//
//  Created by Juliya Smith on 8/20/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class Hormone: PDObject, Hormonal, Comparable {
    
    private let exp: ExpirationIntervalUD
    private let deliveryMethod: DeliveryMethod
    
    private var moHormone: MOHormone { self.mo as! MOHormone }
    
    public init(hormone: MOHormone, interval: ExpirationIntervalUD, deliveryMethod: DeliveryMethod) {
        self.exp = interval
        self.deliveryMethod = deliveryMethod
        super.init(mo: hormone)
    }

    public var id: UUID {
        get {
            moHormone.id ?? {
                moHormone.id = UUID()
                return moHormone.id!
            }()
        } set {
            moHormone.id = newValue
        }
    }
    
    public var site: Bodily? {
        get {
            if let site = moHormone.siteRelationship {
                return Site(
                    moSite: site,
                    globalExpirationInterval: exp,
                    deliveryMethod: deliveryMethod
                )
            }
            return nil
        } set {
            if let newSite = newValue as? Site, let newMOSite = newSite.mo as? MOSite {
                moHormone.siteRelationship = newMOSite
                moHormone.siteNameBackUp = nil
            }
        }
    }

    public var date: Date {
        get { (moHormone.date as Date?) ?? Date.createDefaultDate() }
        set { moHormone.date = newValue as NSDate }
    }

    public var expiration: Date? {
        if let date = date as Date?,
            let expires = DateHelper.expirationDate(from: date, exp.hours) {
            return expires
        }
        return nil
    }

    public var expirationString: String {
        if let date = date as Date?,
            let expires = DateHelper.expirationDate(from: date, exp.hours) {
            return DateHelper.format(date: expires, useWords: true)
        }
        return PDStrings.PlaceholderStrings.dotDotDot
    }

    public var isExpired: Bool {
        if let date = date as Date? {
            let timeInterval = DateHelper.calculateExpirationTimeInterval(exp.hours, date: date)
            return (timeInterval ?? 1) <= 0
        }
        return false
    }
    
    public var expiresOvernight: Bool {
        expiration?.isOvernight() ?? false
    }

    public var siteName: String {
        moHormone.siteRelationship?.name ?? siteNameBackUp ?? ""
    }

    public var siteNameBackUp: String? {
        get { site == nil ? moHormone.siteNameBackUp : nil }
        set {
            moHormone.siteNameBackUp = newValue
            moHormone.siteRelationship = nil
        }
    }

    public var isEmpty: Bool {
        date.isDefault() && site == nil && siteNameBackUp == nil
    }

    public var isCerebral: Bool {
        siteName == SiteStrings.newSite
    }
    
    public func stamp() {
        moHormone.date = NSDate()
    }

    public func reset() {
        moHormone.id = nil
        moHormone.date = nil
        moHormone.siteRelationship = nil
        moHormone.siteNameBackUp = nil
    }
    
    // MARK: - Comparable. nil > all.
    
    public static func < (lhs: Hormone, rhs: Hormone) -> Bool {
        switch(lhs.date, rhs.date) {
        case (nil, nil) : return false
        case (nil, _) : return false
        case (_, nil) : return true
        default : return (lhs.date as Date?)! < (rhs.date as Date?)!
        }
    }
    
    public static func > (lhs: Hormone, rhs: Hormone) -> Bool {
        switch(lhs.date, rhs.date) {
        case (nil, nil) : return false
        case (nil, _) : return true
        case (_, nil) : return false
        default : return (lhs.date as Date?)! > (rhs.date as Date?)!
        }
    }
    
    public static func == (lhs: Hormone, rhs: Hormone) -> Bool {
        switch(lhs.date, rhs.date) {
        case (nil, nil) : return true
        case (nil, _) : return false
        case (_, nil) : return false
        default : return (lhs.date as Date?)! == (rhs.date as Date?)!
        }
    }
    
    public static func != (lhs: Hormone, rhs: Hormone) -> Bool {
        switch(lhs.date, rhs.date) {
        case (nil, nil) : return false
        case (nil, _) : return true
        case (_, nil) : return true
        default : return (lhs.date as Date?)! != (rhs.date as Date?)!
        }
    }
}
