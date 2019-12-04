//
// Created by Juliya Smith on 11/29/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class PillsViewModel: CodeBehindDependencies {

    private var pillsTable: PillsTable

    init(pillsTable: PillsTable) {
        self.pillsTable = pillsTable
        addObserverForUpdatingPillTableWhenEnteringForeground()
        super.init()
    }

    var pills: PillScheduling? {
        sdk?.pills
    }

    func getCell(at index: Index)-> UITableViewCell {
        pillsTable.getCellForRowAt(index)?.configure(at: index, pillIndex: index) ?? UITableViewCell()
    }

    func takePill(at index: Index) {
        if let pills = pills, let pill = pills.at(index) {
            pills.swallow(pill)
            tabs?.reflectDuePillBadgeValue()
            notifications?.requestDuePillNotification(pill)
            self.pillsTable.getCellForRowAt(index)?.stamp().configure(pill, pillIndex: index)
        }
    }

    func deletePill(at index: IndexPath) {
        pills?.delete(at: index.row)
        let pillsCount = pills?.count ?? 0
        pillsTable.deleteCell(at: index, pillsCount: pillsCount)
    }

    func goToPillDetails(pillIndex: Index, pillsViewModel: UIViewController) {
        if let pill = pills?.at(pillIndex) {
            nav?.goToPillDetails(pill, source: pillsViewModel)
        }
    }

    @objc func handleInsertNewPill(pillsViewController: UIViewController) {
        if let pill = pills?.insertNew(completion: pillsTable.reload) {
            nav?.goToPillDetails(pill, source: pillsViewController)
        }
    }

    private func addObserverForUpdatingPillTableWhenEnteringForeground() {
        let name = UIApplication.willEnterForegroundNotification
        NotificationCenter.default.addObserver(
            self, selector: #selector(pillsTable.reload), name: name, object: nil
        )
    }
}
