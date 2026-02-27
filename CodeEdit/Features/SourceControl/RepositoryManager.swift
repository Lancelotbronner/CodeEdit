//
//  RepositoryManager.swift
//  CodeEdit
//
//  Created by Christophe Bronner on 2026-02-26.
//

import Foundation

@Observable @MainActor
final class RepositoryManager {
	nonisolated init() {}

	private var models: [RepositoryModel] = []
}

extension RepositoryManager {
	/// Attempts to load a repository at the given root.
	/// - Parameter url: The root of the file tree.
	/// - Returns: A repository if any.
	func load(at url: URL) async -> RepositoryModel? {
		if let existing = repository(for: url) {
			return existing
		}
		let git = GitClient(directoryURL: url, shellClient: currentWorld.shellClient)
		guard await git.validate() else { return nil }
		let repository = RepositoryModel(for: git)
		models.append(repository)
		return repository
	}

	func repository(for url: URL) -> RepositoryModel? {
		models.first { $0.url.containsSubPath(url) }
	}
}
