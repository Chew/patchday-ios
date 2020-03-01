//
//  PDThemeUD.swift
//  PatchData
//
//  Created by Juliya Smith on 4/28/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation


public class PDThemeUD: PDUserDefault<PDTheme, String>, KeyStorable {

    public static let LightThemeKey = { "Light" }()
    public static let DarkThemeKey = { "Dark" }()
    
    public typealias Value = PDTheme
    public typealias RawValue = String
    public let setting: PDSetting = .Theme
    
    public override var value: PDTheme {
        switch rawValue {
        case PDThemeUD.DarkThemeKey: return .Dark
        default: return .Light
        }
    }
}
