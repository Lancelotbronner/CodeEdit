//
//  WorkspaceManager.swift
//  CodeEdit
//
//  Created by Christophe Bronner on 2026-02-25.
//

import SwiftUI

@Observable @MainActor
final class WorkspaceManager {
	static let shared = WorkspaceManager()
	private init() {}

	private(set) var workspaces: [WorkspaceModel] = []
	var isImporterPresented = false

	var openWindow: OpenWindowAction?
	var openDocument: OpenDocumentAction?

	@ObservationIgnored
	@Service var lspService: LSPService
}

extension WorkspaceManager {
	func register(_ workspace: WorkspaceModel) {

	}

	func unregister(_ workspace: WorkspaceModel) {
		if let path = workspace.fileURL?.absoluteURL.path() {
			lspService.closeWorkspace(path)
		}

		if workspaces.isEmpty {
			switch Settings[\.general].reopenWindowAfterClose {
			case .showWelcomeWindow:
				// Opens the welcome window
				openWindow?(sceneID: .welcome)
			case .quit:
				// Quits CodeEdit
				NSApplication.shared.terminate(nil)
			case .doNothing: break
			}
		}
	}

	func workspace(of url: URL) -> WorkspaceModel? {
		let absolutePath = url.absolutePath
		return workspaces.first {
			// createIfNotFound is safe here because it will still exit if the file and the workspace do not share a path prefix
			$0.workspaceFileManager?.getFile(absolutePath, createIfNotFound: true) != nil
		}
	}

	func open(at url: URL) {
		guard !openFileInExistingWorkspace(url: url) else { return }
		Task { try await openDocument?(at: url) }
	}

	func open(_ file: CEWorkspaceFile) {
		open(at: file.resolvedURL)
	}

	/// Attempt to open the file URL in an open workspace, finding the nearest workspace to open it in if possible.
	/// - Parameter url: The file URL to open.
	/// - Returns: True, if the document was opened in a workspace.
	private func openFileInExistingWorkspace(url: URL) -> Bool {
		guard !url.isFolder else { return false }

		// Check open workspaces for the file being opened. Sorted by shared components with the url so we
		// open the nearest workspace possible.
		for workspace in workspaces.sorted(by: {
			($0.fileURL?.sharedComponents(url) ?? 0) > ($1.fileURL?.sharedComponents(url) ?? 0)
		}) {
			// createIfNotFound will still return `nil` if the files don't share a common ancestor.
			if let newFile = workspace.workspaceFileManager?.getFile(url.absolutePath, createIfNotFound: true) {
				workspace.editorManager.openTab(item: newFile)
				if let workspaceURL = workspace.fileURL {
					Task {
						//TODO: error handling, make sure this just brings the existing workspace to front
						try await openDocument?(at: workspaceURL)
					}
				}
				return true
			}
		}
		return false
	}
}

private struct WorkspaceManagerProxy: ViewModifier {
	@Bindable var manager: WorkspaceManager

	func body(content: Content) -> some View {
		content
			.fileImporter(isPresented: $manager.isImporterPresented, allowedContentTypes: [.item]) { result in
				switch result {
				case let .success(fileURL):
					manager.open(at: fileURL)
				case let .failure(error):
					print(error)
				}
			}
	}
}
