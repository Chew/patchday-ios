//
// Created by Juliya Smith on 12/3/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


class SiteDetailViewModel: CodeBehindDependencies<SiteDetailViewModel> {

    private var site: Bodily
    private let siteIndex: Index
    private var selections = SiteSelectionState()

    let imagePickerDelegate: SiteImagePickerDelegate

    // MARK: - CTOR

    convenience init(_ params: SiteDetailViewModelConstructorParams) {
        let images = PDImages.getAvailableSiteImages(params.imageSelectionParams)
        self.init(
            params.site,
            siteIndex: params.site.order,
            imageSelections: images,
            siteImagePickerRelatedViews: params.relatedViews
        )
    }

    private convenience init(_ site: Bodily, siteIndex: Index, imageSelections: [UIImage], siteImagePickerRelatedViews: SiteImagePickerDelegateRelatedViews) {
        let pickerDelegateProps = SiteImagePickerDelegateProperties(
            selectedSite: site, imageOptions: imageSelections, views: siteImagePickerRelatedViews
        )
        self.init(site, siteIndex: siteIndex, imagePickerProps: pickerDelegateProps)
    }

    private convenience init(_ site: Bodily, siteIndex: Index, imagePickerProps: SiteImagePickerDelegateProperties) {
        let imagePickerDelegate = SiteImagePickerDelegate(props: imagePickerProps)
        self.init(site, siteIndex: siteIndex, imagePickerDelegate: imagePickerDelegate)
    }

    init(_ site: Bodily, siteIndex: Index, imagePickerDelegate: SiteImagePickerDelegate) {
        self.site = site
        self.siteIndex = siteIndex
        self.imagePickerDelegate = imagePickerDelegate
        super.init()
    }

    // MARK: - Public

    var siteDetailViewControllerTitle: String {
        siteName
    }

    var siteName: SiteName {
        site.name
    }

    var sitesCount: Int {
        sdk?.sites.count ?? 0
    }

    var siteNameSelections: [SiteName] {
        sdk?.sites.names ?? []
    }

    var siteNamePickerStartIndex: Index {
        let startName = selections.selectedSiteName ?? siteName
        return siteNameSelections.firstIndex(of: startName) ?? 0
    }

    var siteImage: UIImage {
        guard let defaults = sdk?.settings else { return UIImage() }
        let params = SiteImageDeterminationParameters(
            siteName: siteName,
            deliveryMethod: defaults.deliveryMethod.value,
            theme: defaults.theme.value
        )
        return PDImages.getSiteImage(from: params)
    }

    @discardableResult func saveSiteImageChanges() -> UIImage? {
        guard let row = selections.selectedSiteImageRow else { return nil }
        let image = createImageStruct(selectedRow: row)
        sdk?.sites.setImageId(at: row, to: image.name)
        return image.image
    }

    func handleSave(siteNameText: SiteName?, siteDetailViewController: SiteDetailViewController) {
        if let name = siteNameText {
            saveSiteNameChanges(siteName: name)
        }
        nav?.pop(source: siteDetailViewController)
    }

    func getSiteName(at index: Index) -> SiteName? {
        siteNameSelections.tryGet(at: index)
    }

    func getAttributedSiteName(at index: Index) -> NSAttributedString? {
        guard let siteRowName = getSiteName(at: index) else { return nil }
        guard let color = styles?.theme[.text] else { return nil }
        let attributes = [NSAttributedString.Key.foregroundColor : color as Any]
        return NSAttributedString(string: siteRowName, attributes: attributes)
    }

    // MARK: - Private

    private func createImageStruct(selectedRow: Index) -> SiteImageStruct {
        guard let settings = sdk?.settings else {
            return createImageStruct(
                selectedRow: selectedRow,
                method: DefaultSettings.DeliveryMethodValue,
                theme: DefaultSettings.ThemeValue
            )
        }
        let method = settings.deliveryMethod.value
        let theme = settings.theme.value
        return createImageStruct(selectedRow: selectedRow, method: method, theme: theme)
    }
    
    private func createImageStruct(selectedRow: Index, method: DeliveryMethod, theme: PDTheme) -> SiteImageStruct {
        let params = SiteImageDeterminationParameters(deliveryMethod: method, theme: theme)
        let images = PDImages.getAvailableSiteImages(params)
        let image = images[selectedRow]
        let imageKey = PDImages.getSiteName(from: image)
        return SiteImageStruct(image: image, name: imageKey)
    }

    private func saveSiteNameChanges(siteName: SiteName) {
        guard let sites = sdk?.sites else { return }
        if siteIndex >= 0 && siteIndex < sites.count {
            sites.rename(at: siteIndex, to: siteName)
        } else if siteIndex == sites.count {
            sites.insertNew(name: siteName, save: true, onSuccess: nil)
        }
    }
}
