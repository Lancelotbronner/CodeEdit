//
//  TabModel.swift
//  CodeEdit
//
//  Created by Christophe Bronner on 2026-03-10.
//

import Foundation

@Observable @MainActor
final class TabModel {
	init() {}

	/// The pane to which this tab is assigned.
	weak var pane: PaneModel?

	/// The item currently displayed by this tab.
	/// If nil, shows quick open
	var item: ItemModel? {
		didSet {
			guard let item else { return }
			print("Open \(item.url)")
		}
	}

	/// The project navigator selection.
	var projectSelection: Set<ItemModel> = [] {
		didSet {
			guard projectSelection.count == 1 else { return }
			item = projectSelection.first
		}
	}
}
