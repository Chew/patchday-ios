//
//  HormoneDetailViewModelProtocol.swift
//  PDKit
//
//  Created by Juliya Smith on 11/8/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation

public protocol HormoneDetailViewModelProtocol {
    var nav: NavigationHandling? { get }
    var hormoneId: UUID? { get }
    var hormone: Hormonal? { get }
    var selections: HormoneSelectionState { get set }
    var handleInterfaceUpdatesFromNewSite: () -> Void { get }
    var dateSelected: Date? { get set }
    var dateSelectedText: String { get }
    var datePickerDate: Date { get }
    var selectDateStartText: String { get }
    var selectSiteStartText: String { get }
    var expirationDateText: String { get }
    var siteStartRow: Index { get }
    var siteCount: Int { get }
    var autoPickedDateText: String { get }
    var autoPickedExpirationDateText: String { get }
    func handleIfUnsaved(_ viewController: UIViewController)
    func selectSuggestedSite() -> String
    func getSiteName(at row: Index) -> SiteName?
    func createHormoneViewStrings() -> HormoneViewStrings?
    @discardableResult func trySelectSite(at row: Index) -> String?
    func saveSelections()
    func extractSiteNameFromTextField(_ siteTextField: UITextField) -> String
    func presentNewSiteAlert(newSiteName: String)
}
