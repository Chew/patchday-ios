//
//  PillsVC.swift
//  PatchDay
//
//  Created by Juliya Smith on 12/16/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


typealias PillName = String

class PillsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private var viewModel: PillsViewModel!
    private var viewFactory: PillsViewFactory!
    
    @IBOutlet var pillsView: UIView!
    @IBOutlet weak var pillsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViewModelIfNil()
        applyTheme()
        title = ViewTitleStrings.PillsTitle
        pillsTableView.delegate = self
        pillsTableView.dataSource = self
        loadBarButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initViewModelIfNil()
        viewModel.pillsTable.reloadData()
        reloadInputViews()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.pillsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        viewModel.pillsTable[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.presentPillActions(at: indexPath.row, viewController: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        PillCell.RowHeight
    }
    
    func tableView(
        _ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        viewModel.createPillCellSwipeActions(index: indexPath)
    }
    
    @IBAction func takeButtonTapped(_ sender: Any) {
        guard let pillIndex = (sender as? UIButton)?.restoreSuffix() else  { return }
        viewModel.takePill(at: pillIndex)
    }

    // MARK: - Private / Helpers

    private func initViewModelIfNil() {
        guard viewModel == nil else { return }
        viewFactory = PillsViewFactory(insertButtonAction: handleInsertNewPill)
        viewModel = PillsViewModel(pillsTableView: pillsTableView, viewFactory: viewFactory)
    }
    
    private func loadBarButtons() {
        let insertButton = viewFactory.createInsertButton()
        navigationItem.rightBarButtonItems = [insertButton]
        let backItem = PDViewFactory.createTextBarButtonItem(ViewTitleStrings.PillTitle)
        navigationItem.backBarButtonItem = backItem
    }
    
    private func applyTheme() {
        pillsView.backgroundColor = UIColor.systemBackground
    }
    
    @objc private func handleInsertNewPill() {
        viewModel.goToNewPillDetails(pillsViewController: self)
    }
}
