//
//  MOEstrogenDeliveryMethods.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/2/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation
import CoreData

    //Description: MOEstrogenDelivery is a managed object class that represents either a Patch or an Injection.  MOEstrogenDelivery objects are abstractions of patches on the physical body or injections into the body.  They have two attributes: 1.) the date/time placed or injected, and 2.), the location placed or injected.  MOEstrogenDelivery.expirationDate() or MOEstrogenDelivery.expirationDateAsString() are useful in the Schedule.

    // This file is an extension of the Patch object to include useful methods.

extension MOEstrogenDelivery {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MOEstrogenDelivery> {
        return NSFetchRequest<MOEstrogenDelivery>(entityName: PDStrings.entityName)
    }

    //MARK: - setters
    
   public func setDatePlaced(withDate: Date) {
        self.datePlaced = withDate
    }
    
    public func setDatePlaced(withString: String) {
        let dateFormatter = DateFormatter()
        self.datePlaced = dateFormatter.date(from: withString)
    }
    
    public func setLocation(with: String) {
        self.location = with
    }
    
    // MARK: - getters
    
    public func getdate() -> Date? {
        return self.datePlaced
    }
    
    // getLocation() : will return a string indicating non-located instead of nil
    public func getLocation() -> String {
        guard let location = self.location else {
            return PDStrings.unplaced_string
        }
        
        // For switching over from legacy location names
        switch location {
        case "Left Stomach":
            return "Left Abdomen"
        case "Right Stomach":
            return "Right Abdomen"
        case "Left Buttock":
            return "Left Glute"
         case "Right Buttock":
            return "Right Glute"
        case "Left Thigh":
            return "Left Quad"
        case "Right Thigh":
            return "Right Quad"
        default:
            return location
        }
    }
    
    // MARK: - mutators
    
    public func progressToNow() {
        self.datePlaced = Date()
    }
    
    public func reset() {
        self.datePlaced = nil
        self.location = PDStrings.unplaced_string
    }
    
    // MARK: - strings
    
    public func string() -> String {
        return self.getDatePlacedAsString() + "," + self.getLocation()
    }
    
    public func getDatePlacedAsString() -> String {
        guard let dateAdded = self.datePlaced else {
            return PDStrings.unplaced_string
        }
        return MOEstrogenDelivery.makeDateString(from: dateAdded, useWords: true)
    }
    
    public func expirationDateAsString(timeInterval: String, useWords: Bool) -> String {
        if self.getdate() == nil {
            return PDStrings.hasNoDate
        }
        let expires = self.expirationDate(timeInterval: timeInterval)
        return MOEstrogenDelivery.makeDateString(from: expires, useWords: useWords)
    }
    
    // MARK: - booleans
    
    public func hasNoDate() -> Bool {
        return self.datePlaced == nil
    }
    
    public func isEmpty() -> Bool {
        let loc = self.location?.lowercased()
        return self.datePlaced == nil && loc == "unplaced"
    }
    
    public func isCustomLocated() -> Bool {
        let loc = self.getLocation().lowercased()
        return !PDStrings.patchLocationNames.contains(self.getLocation()) && !PDStrings.injectionLocationNames.contains(self.getLocation()) && loc != "unplaced"
    }
    
    public func isExpired(timeInterval: String) -> Bool {
        if let intervalUntilExpiration = self.determineIntervalToExpire(timeInterval: timeInterval) {
            return self.getdate() != nil && intervalUntilExpiration <= 0
        }
        return false
    }
    
    // notificationMessage(timeInterval) : determined the proper message for related notifications.  This depends on the location property.
    public func notificationMessage(timeInterval: String) -> String {
        if !self.isCustomLocated() {
            guard let locationNotificationPart = PDStrings.expiredPatchNotificationIntros[getLocation()] else {
                return PDStrings.notificationExpiredPatchWithoutLocation + self.expirationDateAsString(timeInterval: timeInterval, useWords: false)
            }
            return locationNotificationPart + self.expirationDateAsString(timeInterval: timeInterval, useWords: false)
        }
            
            // for custom locations
        else {
            let locationNotificationPart = PDStrings.expiredPatchNotificationIntroForCustom + self.getLocation() + " " + PDStrings.expiredPatchNotificationIntroForCustom_at
            return locationNotificationPart + self.expirationDateAsString(timeInterval: timeInterval, useWords: false)
        }
    }
    
    // MARK: - selectors
    
    public func expirationDate(timeInterval: String) -> Date {
        let hoursLasts = MOEstrogenDelivery.calculateHours(of: timeInterval)
        let calendar = Calendar.current
        guard let dateAdded = self.getdate() else {
            return Date()
        }
        guard let expDate = calendar.date(byAdding: .hour, value: hoursLasts, to: dateAdded) else {
            return Date()
        }
        return expDate
    }
    
    public func determineIntervalToExpire(timeInterval: String) -> TimeInterval? {
        if self.getdate() != nil {
            let expirationDate = self.expirationDate(timeInterval: timeInterval)
            let now = Date()
            // for non-expired times, pos exp time
            if expirationDate >= now {
                return DateInterval(start: now, end: expirationDate).duration
            }
            // for expired, neg exp time
            else {
                return -DateInterval(start: expirationDate, end: now).duration
            }
        }
        return nil
        
    }
    
    // calculateHours(of) : returns a the integer of number of hours of the inputted expiration interval
    static public func calculateHours(of: String) -> Int {
        var numberOfHours: Int
        switch of {
        case PDStrings.expirationIntervals[1]:
            numberOfHours = 168
            break
        case PDStrings.expirationIntervals[2]:
            numberOfHours = 336
            break
        default:
            numberOfHours = 84
        }
        return numberOfHours
    }
        
    // MARK: - static
    
    static public func makeDateString(from: Date, useWords: Bool) -> String {
        let dateFormatter = DateFormatter()
        if useWords, let word = MOEstrogenDelivery.dateWord(from: from) {
            dateFormatter.dateFormat = "h:mm a"
            return word + ", " + dateFormatter.string(from: from)
        }
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy, h:mm a"
        return dateFormatter.string(from: from)
    }
    
    static public func expiredDate(fromDate: Date) -> Date? {
        let hours: Int = self.calculateHours(of: UserDefaultsController.getTimeInterval())
        let calendar = Calendar.current
        guard let expDate = calendar.date(byAdding: .hour, value: hours, to: fromDate) else {
            return nil
        }
        return expDate
        
    }
    
    public static func dayOfWeekString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        if let word = MOEstrogenDelivery.dateWord(from: date) {
            dateFormatter.dateFormat = "h:mm a"
            return word + ", " + dateFormatter.string(from: date)
        }
        dateFormatter.dateFormat = "EEEE, h:mm a"
        return dateFormatter.string(from: date)
    }
    
    // MARK: - helpers
    
    private static func dateWord(from: Date) -> String? {
        let calendar = Calendar.current
        if calendar.isDateInToday(from) {
            return PDStrings.today_title
        }
        else if let yesterday = PillDataController.getDate(at: Date(), daysToAdd: -1), calendar.isDate(from, inSameDayAs: yesterday) {
            return PDStrings.yesterday_title
        }
        else if let tomorrow = PillDataController.getDate(at: Date(), daysToAdd: 1), calendar.isDate(from, inSameDayAs: tomorrow) {
            return PDStrings.tomorrow_title
        }
        return nil
    }

}
