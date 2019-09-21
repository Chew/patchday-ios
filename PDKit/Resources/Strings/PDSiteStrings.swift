//
//  PDSiteStrings.swift
//  PDKit
//
//  Created by Juliya Smith on 5/6/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public class PDSiteStrings {
    
    private static let commonComment = { return "Displayed all over the app. Abbreviate if it is more than 2x as long." }()
    
    public static let unplaced = {
        return NSLocalizedString("unplaced", comment: commonComment)
    }()
    
    public struct SiteNames {
        
        static let patchSiteNames: [String] = {
            let comment = commonComment
            return [NSLocalizedString("Right Glute", tableName: nil, comment: comment),
                    NSLocalizedString("Left Glute", tableName: nil, comment: comment),
                    NSLocalizedString("Right Abdomen", tableName: nil, comment: comment),
                    NSLocalizedString("Left Abdomen", tableName: nil, comment: comment)]
        }()
        
        public static let rightAbdomen = { return patchSiteNames[2] }()
        public static let leftAbdomen = { return patchSiteNames[3] }()
        public static let rightGlute = { return patchSiteNames[0] }()
        public static let leftGlute = { return patchSiteNames[1] }()
        
        static let injectionSiteNames: [String] =  {
            let comment = commonComment
            return [NSLocalizedString("Right Quad", comment: comment),
                    NSLocalizedString("Left Quad", comment: comment),
                    NSLocalizedString("Right Glute", comment: comment),
                    NSLocalizedString("Left Glute", comment: comment),
                    NSLocalizedString("Right Delt", comment: comment),
                    NSLocalizedString("Left Delt", comment: comment)]
        }()
        
        public static let rightQuad = { return injectionSiteNames[0] }()
        public static let leftQuad = { return injectionSiteNames[1] }()
        public static let rightDelt = { return injectionSiteNames[4] }()
        public static let leftDelt = { return injectionSiteNames[5] }()
    }
    
    public static func getSiteNames(for method: DeliveryMethod) -> [String] {
        switch method {
        case .Patches:
            return SiteNames.patchSiteNames
        case .Injections:
            return SiteNames.injectionSiteNames
        }
    }
}
