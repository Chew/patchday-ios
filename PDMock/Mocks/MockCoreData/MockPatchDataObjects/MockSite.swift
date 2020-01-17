//
//  MockSite.swift
//  PDMock
//
//  Created by Juliya Smith on 1/12/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


public class MockSite: Bodily, PDMocking {
    
    // Mock-related properties
    public var isOccupiedCallArgs: [Int] = []
    public var isOccupiedReturnValues: [Bool] = []
    public var isEqualToCallArgs: [Bodily] = []
    public var isEqualToReturnValues: [Bool] = []
    public var resetCallCount = 0
    
    // Bodily properties
    public var id: UUID = UUID()
    public var hormoneIds: [UUID] = []
    public var hormoneCount: Int = 0
    public var imageId: String = ""
    public var name: SiteName = ""
    public var order: Int = -1
    public var isOccupied: Bool = false
    
    public init() {}
    
    public func resetMock() {
        isOccupiedCallArgs = []
        isOccupiedReturnValues = []
        isEqualToCallArgs = []
        isEqualToReturnValues = []
        resetCallCount = 0
    }
    
    public func isOccupied(byAtLeast thisMany: Int) -> Bool {
        isOccupiedCallArgs.append(thisMany)
        if let v = isOccupiedReturnValues.tryGet(at: 0) {
            isOccupiedReturnValues.remove(at: 0)
            return v
        }
        return false
    }
    
    public func isEqualTo(_ otherSite: Bodily) -> Bool {
        isEqualToCallArgs.append(otherSite)
        if let v = isEqualToReturnValues.tryGet(at: 0) {
            isEqualToReturnValues.remove(at: 0)
            return v
        }
        return false
    }
    
    public func reset() {
        resetCallCount += 1
    }
}
