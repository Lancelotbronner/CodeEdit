//
//  WorkspaceModel.swift
//  CodeEdit
//
//  Created by Christophe Bronner on 2026-02-25.
//

import SwiftUI
import UniformTypeIdentifiers

final class WorkspaceDocument: ReferenceFileDocument, @unchecked Sendable {
	static let readableContentTypes = [UTType.item]
	//TODO: writableContentTypes is workspace only

	let model = WorkspaceModel()

	init() {}

	init(configuration: ReadConfiguration) throws {}
}

extension WorkspaceDocument {
	struct Snapshot {
		//TODO: url security scope bookmarks
	}

	func snapshot(contentType: UTType) throws -> Snapshot {
		Snapshot()
	}

	func fileWrapper(snapshot: Snapshot, configuration: WriteConfiguration) throws -> FileWrapper {
		configuration.existingFile ?? FileWrapper()
	}

	@MainActor
	func load(using configuration: ReferenceFileDocumentConfiguration<WorkspaceDocument>) async throws {
		guard let url = configuration.fileURL else { return }
		try await model.initWorkspaceState(url)
	}
}
