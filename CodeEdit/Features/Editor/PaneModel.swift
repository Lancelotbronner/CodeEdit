//
//  PaneModel.swift
//  CodeEdit
//
//  Created by Christophe Bronner on 2026-03-10.
//

import Foundation

@Observable @MainActor
final class PaneModel {
	/// The tabs of this pane.
	var tabs: [Weak<TabModel>] = []
}

extension PaneModel {
	var isSingleTab: Bool {
		tabs.removeAll(where: \.isNone)
		return tabs.count == 1
	}
}
