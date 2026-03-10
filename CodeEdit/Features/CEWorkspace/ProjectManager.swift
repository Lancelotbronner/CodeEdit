//
//  ProjectManager.swift
//  CodeEdit
//
//  Created by Christophe Bronner on 2026-02-26.
//

import SwiftUI

@Observable @MainActor
final class ProjectManager {
	var ignored: Set<String> = [".DS_Store", ".git"]
	private var models: [CEWorkspaceFileManager] = []
	var roots: [ItemModel] = []

	//TODO: reimplement
	var sortFoldersOnTop = true

	var query = ""
	/// Whether the workspace only shows files with changes.
	var isModified = false
	/// Whether the workspace only shows files that were recently opened.
	var isRecent = false

	nonisolated init() {}
}

extension ProjectManager {
	var isEmpty: Bool {
		models.isEmpty
	}

	var isFilterEmpty: Bool {
		query.isEmpty && !isModified && !isRecent
	}

	/// Returns whether the provided item matches the current filter.
	/// - Parameter item: The item to test.
	/// - Returns: `true` if the item matches the filter, `false` otherwise.
	func contains(_ item: ItemModel) -> Bool {
		guard !ignored.contains(item.displayName) else { return false }
		let queryMatches = query.isEmpty || item.displayName.localizedCaseInsensitiveContains(query)
		//TODO: other parts of the filter
		return queryMatches
	}

	/// Loads a root at the given root.
	/// - Parameter url: The root of the file tree.
	/// - Returns: A repository if any.
	func getOrCreate(at url: URL) -> CEWorkspaceFileManager {
		if let existing = files(for: url) {
			return existing
		}
		let model = CEWorkspaceFileManager(folderUrl: url, ignoredFilesAndFolders: [], in: nil)
		models.append(model)
		return model
	}

	/// Adds the given URL to the project.
	func addIfNew(at url: URL) {
		guard !contains(url) else { return }
		let model = ItemModel.root(at: url)
		roots.append(model)
	}

	func contains(_ url: URL) -> Bool {
		roots.contains { $0.url.containsSubPath(url) }
	}

	func files(for url: URL) -> CEWorkspaceFileManager? {
		models.first { $0.folderUrl.containsSubPath(url) }
	}
}
