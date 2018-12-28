//
//  PDScheduleProtocol.swift
//  PatchData
//
//  Created by Juliya Smith on 12/28/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation
import CoreData

public class PDScheduleProtocol: NSObject {

    /// Return the number of Managed Objects in the schedule
    func count() -> Int {
        fatalError("Must Override")
    }

    /// Create + Insert a new Managed Object
    func insert() -> NSManagedObject? {
        fatalError("Must Override")
    }

    /// Reset the schedule to a default
    func reset() {
        fatalError("Must Override")
    }
}
