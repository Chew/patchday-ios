//
//  MOEstrogenMethods.swift
//  PDKit
//
//  Created by Juliya Smith on 7/13/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//
//

import Foundation
import CoreData


extension MOEstrogen {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MOEstrogen> {
        return NSFetchRequest<MOEstrogen>(entityName: "Estrogen")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var id: UUID?
    @NSManaged public var siteNameBackUp: String?
    @NSManaged public var siteRelationship: MOSite?
    
    
    // MARK: - Getters and setters
    
    public func setSite(with site: MOSite?) {
        self.siteRelationship = site
        self.siteNameBackUp = nil
    }
    
    public func setDate(with date: NSDate) {
        self.date = date
    }
    
    public func setID(with newID: UUID) {
        self.id = newID
    }
    
    public func setSiteBackup(to str: String) {
        self.siteNameBackUp = str        
        self.siteRelationship = nil
    }
    
    public func getSite() -> MOSite? {
        return self.siteRelationship
    }
    
    public func getDate() -> NSDate? {
        return self.date
    }
    
    public func getID() -> UUID? {
        return self.id
    }
    
    public func getSiteNameBackUp() -> String? {
        if siteRelationship == nil {
            return self.siteNameBackUp
        }
        return nil
    }
    
    public func getSiteName() -> String {
        if let site = getSite(), let name = site.getName() {
            return name
        }
        else if let name = getSiteNameBackUp() {
            return name
        }
        else {
            return PDStrings.PlaceholderStrings.new_site
        }
    }
    
    /// Sets all attributes to nil.
    public func reset() {
        date = nil
        siteRelationship = nil
        siteNameBackUp = nil
    }
    
    // MARK: - Strings
    
    public func string() -> String {
        var estroString = getDatePlacedAsString()
        if let site = getSite(), let siteName = site.getName() {
            estroString += ", " + siteName
        }
        return estroString
    }
    
    public func getDatePlacedAsString() -> String {
        guard let dateAdded = date else {
            return PDStrings.PlaceholderStrings.unplaced
        }
        return PDDateHelper.format(date: dateAdded as Date, useWords: true)
    }
    
    public func expirationDate(intervalStr: String) -> Date? {
        if let date = getDate(), let expires = PDDateHelper.expirationDate(from: date as Date, intervalStr) {
            return expires
        }
        return nil
    }
    
    public func expirationDateAsString(_ intervalStr: String, useWords: Bool) -> String {
        if let date = getDate(), let expires = PDDateHelper.expirationDate(from: date as Date, intervalStr) {
            return PDDateHelper.format(date: expires, useWords: useWords)
        }
        
        return PDStrings.PlaceholderStrings.dotdotdot
    }
    
    // MARK: - Booleans
    
    public func isExpired(_ intervalStr: String) -> Bool {
        if let date = getDate(), let intervalUntilExpiration = PDDateHelper.expirationInterval(intervalStr, date: date as Date) {
            return intervalUntilExpiration <= 0
        }
        return false
    }
    
    public func hasNoDate() -> Bool {
        return date == nil
    }
    
    public func isEmpty() -> Bool {
        return date == nil && siteRelationship == nil && siteNameBackUp == nil
    }
    
    /// Returns if the Estrogen is located somewhere not in the default PatchDay sites.
    public func isCustomLocated(usingPatches: Bool) -> Bool {
        let siteName = getSiteName()
        return !PDSiteHelper.isContainedInDefaults(siteName, usingPatches: usingPatches)
    }
    
}
