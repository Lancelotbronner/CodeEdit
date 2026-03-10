//
//  EditorManager2.swift
//  CodeEdit
//
//  Created by Christophe Bronner on 2026-03-10.
//

import Foundation

// An editor has a set of tabs and settings.
// The layout places editors at the right spot.
// Navigator selection is associated to tabs.

@Observable @MainActor
final class EditorManager2 {
	nonisolated init() {}

	/// The tabs currently open.
	var tabs: [TabModel] = []
	/// The panes currently open.
	var panes: [PaneModel] = []
	//TODO: layout with split view info

	/// The tab currently focused.
	var activeTab = TabModel()
}

extension EditorManager2 {
	var isSingleTab: Bool {
		panes.allSatisfy(\.isSingleTab)
	}
}
