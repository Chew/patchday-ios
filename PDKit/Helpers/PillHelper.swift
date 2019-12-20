//
//  PillsHelper.swift
//  PDKit
//
//  Created by Juliya Smith on 6/20/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

public typealias Stamp = Date
public typealias Stamps = [Stamp?]?


public class PillHelper: NSObject {

    public enum NextDueDateError: Error {
        case notEnoughTimes
    }
    
    /// Return the next time the pill is due.
    public static func nextDueDate(_ params: PillDueDateFinderParams) throws -> Date? {
        // Error with times
        if params.times.count == 0 || params.times.count < params.timesaday {
            throw NextDueDateError.notEnoughTimes
        }
        
        let times_today = min(params.timesTakenToday, params.timesaday)
        
        switch(times_today) {
        case 0: return DateHelper.getDate(on: Date(), at: params.times.sorted()[0])
        case (params.timesaday): return DateHelper.getDate(at: params.times.sorted()[0], daysFromNow: 1)
        default: return DateHelper.getDate(on: Date(), at: params.times.sorted()[times_today])
        }
    }
    
    /// Return if the pill has been taken all of its times today.
    public static func isDone(timesTakenToday: Int, timesaday: Int) -> Bool {
        timesTakenToday >= timesaday
    }
}
