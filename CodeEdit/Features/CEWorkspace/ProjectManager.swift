//
//  ProjectManager.swift
//  CodeEdit
//
//  Created by Christophe Bronner on 2026-02-26.
//

import SwiftUI

@Observable @MainActor
final class ProjectManager {
	private var ignored: Set<String> = [".DS_Store"]
	private var models: [CEWorkspaceFileManager] = []

	nonisolated init() {}
}

extension ProjectManager {
	/// Attempts to load a repository at the given root.
	/// - Parameter url: The root of the file tree.
	/// - Returns: A repository if any.
	func load(at url: URL) -> CEWorkspaceFileManager? {
		if let existing = files(for: url) {
			return existing
		}
		let model = CEWorkspaceFileManager(folderUrl: url, ignoredFilesAndFolders: [], in: nil)
		models.append(model)
		return model
	}

	func files(for url: URL) -> CEWorkspaceFileManager? {
		models.first { $0.folderUrl.containsSubPath(url) }
	}
}
