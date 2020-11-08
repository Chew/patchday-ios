//
//  SitesViewController.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/10/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

class SitesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var sitesView: UIView!
    @IBOutlet var sitesTableView: UITableView!

    private var viewModel: SitesViewModelProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()
        willEnterForeground()
        sitesTableView.delegate = self
        sitesTableView.dataSource = self
        loadTitle()
    }

    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        willEnterForeground()
        super.viewDidAppear(animated)
    }

    @objc func willEnterForeground() {
        initViewModel()
        applyTheme()
        viewModel.table.reloadData()
        loadBarButtons()
    }

    // MARK: - Table and cell characteristics.

    func numberOfSections(in tableView: UITableView) -> Int {
        DefaultNumberOfPickerComponents
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        viewModel.createSiteCellSwipeActions(indexPath: indexPath)
    }

    // Row select action
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.goToSiteDetails(siteIndex: indexPath.row, sitesViewController: self)
    }

    // Movable
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        viewModel.isValidSiteIndex(indexPath.row)
    }

    // Highlightable
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        viewModel.isValidSiteIndex(indexPath.row)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.sitesOptionsCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        viewModel.table[indexPath.row] as! UITableViewCell
    }

    // MARK: - Editing cells in the table

    // Permit editing at index
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        viewModel.isValidSiteIndex(indexPath.row)
    }

    // Editing style
    func tableView(
        _ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath
    ) -> UITableViewCell.EditingStyle {
            .delete
    }

    // Indentation for edit mode
    func tableView(_ tableView: UITableView,
        shouldIndentWhileEditingRowAt indexPath: IndexPath
    ) -> Bool {
        viewModel.isValidSiteIndex(indexPath.row)
    }

    // Delete cell (deletes MOSite)
    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        viewModel.deleteFromEditingStyle(style: editingStyle, at: indexPath)
    }

    // Reorder cell
    func tableView(
        _ tableView: UITableView,
        moveRowAt sourceIndexPath: IndexPath,
        to destinationIndexPath: IndexPath
    ) {
        viewModel.reorderSites(
            sourceRow: sourceIndexPath.row, destinationRow: destinationIndexPath.row
        )
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        viewModel.table.rowHeight
    }

    // MARK: - Actions

    @objc func editTapped() {
        let props = createBarItemProps()
        switchNavItems(barItemEditProps: props)
        viewModel.toggleEdit(props)
    }

    @objc func insertTapped() {
        viewModel.handleSiteInsert(sitesViewController: self)
    }

    @objc func resetTapped() {
        loadTitle()
        viewModel.resetSites()
        sitesTableView.isEditing = false
        sitesTableView.reloadData()
        viewModel.table.reloadCells()
    }

    // MARK: - Private

    private func initViewModel() {
        viewModel = SitesViewModel(sitesTableView: sitesTableView)
    }

    private func createBarItemProps() -> BarItemInitializationProperties {
        SiteValueTypeFactory.createBarItemInitProps(
            #selector(resetTapped), #selector(insertTapped), self
        )
    }

    private func switchNavItems(barItemEditProps props: BarItemInitializationProperties) {
        guard var barItems = navigationItem.rightBarButtonItems else { return }
        guard barItems.count >= 2 else { return }
        barItems[0] = SiteViewFactory.createItemFromActionState(props)
        barItems[1].title = props.oppositeActionTitle
        navigationItem.rightBarButtonItems = barItems
    }

    private func loadBarButtons() {
        let sitesBarItems = viewModel.createBarItems(
            insertAction: #selector(insertTapped),
            editAction: #selector(editTapped),
            sitesViewController: self
        )
        navigationItem.rightBarButtonItems = sitesBarItems
    }

    private func loadTitle() {
        title = PDTitleStrings.SitesTitle
    }

    private func applyTheme() {
        sitesView.backgroundColor = UIColor.systemBackground
    }
}
