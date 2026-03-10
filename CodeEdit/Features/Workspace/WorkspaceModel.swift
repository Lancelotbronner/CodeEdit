//
//  WorkspaceModel.swift
//  CodeEdit
//
//  Created by Christophe Bronner on 2026-02-27.
//

import SwiftUI
import Combine
import UniformTypeIdentifiers

@Observable
final class WorkspaceModel {
	var sortFoldersOnTop: Bool = true
	/// A string used to filter the displayed files and folders in the project navigator area based on user input.
	var navigatorFilter: String = ""
	/// Whether the workspace only shows files with changes.
	var sourceControlFilter = false

	var fileURL: URL?
	var displayName = String(localized: "Untitled")

	let editorManager = EditorManager()
	let statusBarViewModel = StatusBarViewModel()
	let utilityAreaModel = UtilityAreaViewModel()
	var searchState: SearchState?
	var openQuicklyViewModel: OpenQuicklyViewModel?
	var commandsPaletteState: QuickActionsViewModel?
	let listenerModel = WorkspaceNotificationModel()
	/// The project structure loaded by this workspace.
	var project = ProjectManager()
	var editor = EditorManager2()
	/// Manager for all the repositories loaded by this workspace.
	var repositories = RepositoryManager()

	/// Whether to present a file importer that adds a new root to the workspace.
	var isAddToWorkspacePresented = false

	var workspaceFileManager: CEWorkspaceFileManager? {
		fileURL.flatMap(project.files)
	}

	var workspaceRepository: RepositoryModel? {
		fileURL.flatMap(repositories.repository)
	}

	var taskManager: TaskManager?
	var workspaceSettingsManager: WorkspaceSettingsManager?
	let taskNotificationHandler = TaskNotificationHandler()

	let undoRegistration = UndoManagerRegistration()

	let notificationPanel = NotificationPanelViewModel()
	private var cancellables = Set<AnyCancellable>()

	init() {
		notificationPanel.workspace = self

		Task {
			await WorkspaceManager.shared.register(self)
		}
	}

	deinit {
		cancellables.forEach { $0.cancel() }
		NotificationCenter.default.removeObserver(self)
	}
}

extension WorkspaceModel {
	private var workspaceState: [String: Any] {
		get {
			let key = "workspaceState-\(self.fileURL?.absoluteString ?? "")"
			return UserDefaults.standard.object(forKey: key) as? [String: Any] ?? [:]
		}
		set {
			let key = "workspaceState-\(self.fileURL?.absoluteString ?? "")"
			UserDefaults.standard.set(newValue, forKey: key)
		}
	}

	func getFromWorkspaceState(_ key: WorkspaceStateKey) -> Any? {
		return workspaceState[key.rawValue]
	}

	func addToWorkspaceState(key: WorkspaceStateKey, value: Any?) {
		if let value {
			workspaceState.updateValue(value, forKey: key.rawValue)
		} else {
			workspaceState.removeValue(forKey: key.rawValue)
		}
	}

	// MARK: NSDocument

	/*
	override static var autosavesInPlace: Bool {
		false
	}

	override var isDocumentEdited: Bool {
		false
	}
	 */

	/*
	override func makeWindowControllers() {
		let window = NSWindow(
			contentRect: NSRect(x: 0, y: 0, width: 1400, height: 900),
			styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
			backing: .buffered,
			defer: false
		)
		// Note For anyone hoping to switch back to a Root-SwiftUI window:
		// See Commit 0200c87 for more details and to see what was previously here.
		// -----
		// Setting the "min size" like this is hacky, but SwiftUI overrides the contentRect and
		// any of the built-in window size functions & autosave stuff. So we have to set it like this.
		// SwiftUI also ignores this value, so it just manages to set the initial window size. *Hopefully* this
		// is fixed in the future.
		// ----
		let windowController = CodeEditWindowController(
			window: window,
			workspace: self
		)

		if let rectString = getFromWorkspaceState(.workspaceWindowSize) as? String {
			window.setFrame(NSRectFromString(rectString), display: true, animate: false)
		} else {
			window.setFrame(NSRect(x: 0, y: 0, width: 1400, height: 900), display: true, animate: false)
			window.center()
		}

		window.setAccessibilityIdentifier("workspace")
		window.setAccessibilityDocument(self.fileURL?.absoluteString)

		self.addWindowController(windowController)

		window.makeKeyAndOrderFront(nil)
	}
	 */

	// MARK: Set Up Workspace

	@MainActor func initWorkspaceState(_ url: URL) async throws {
		// Ensure the URL ends with a "/" to prevent certain URL(filePath:relativeTo) initializers from
		// placing the file one directory above our workspace. This quick fix appends a "/" if needed.
		var url = url
		if !url.absoluteString.hasSuffix("/") {
			url = URL(filePath: url.absoluteURL.path(percentEncoded: false) + "/")
		}

		self.fileURL = url
		self.displayName = url.lastPathComponent

		async let _ = project.getOrCreate(at: url)
		async let _ = repositories.load(at: url)

		self.searchState = .init(self)
		self.openQuicklyViewModel = .init(fileURL: url)
		self.commandsPaletteState = .init()
		self.workspaceSettingsManager = WorkspaceSettingsManager(workspaceURL: url)
		if let workspaceSettingsManager {
			self.taskManager = TaskManager(
				workspaceSettings: workspaceSettingsManager.settings,
				workspaceURL: url
			)
		}
		self.taskNotificationHandler.workspaceURL = url

		workspaceFileManager?.addObserver(undoRegistration)
		editorManager.restoreFromState(self)
		utilityAreaModel.restoreFromState(self)
	}

	// MARK: Close Workspace

	/// Determines the windows should be closed.
	///
	/// This method iterates all edited documents If there are any edited documents.
	///
	/// A panel giving the user the choice of canceling, discarding changes, or saving is presented while iteration.
	///
	/// If the user chooses cancel on the panel, iteration is broken.
	///
	/// In the last step, `shouldCloseSelector` is called with true if all documents are clean, otherwise false
	///
	/// - Parameters:
	///
	///
	///
	///
	func shouldClose() -> Bool {
		// Save unsaved changes before closing
		let editedCodeFiles = editorManager.editorLayout
			.gatherOpenFiles()
			.compactMap(\.fileDocument)
			.filter(\.isDocumentEdited)

		/*
		for editedCodeFile in editedCodeFiles {
			let shouldClose = UnsafeMutablePointer<Bool>.allocate(capacity: 1)
			shouldClose.initialize(to: true)
			defer {
				_ = shouldClose.move()
				shouldClose.deallocate()
			}
			// Present a panel giving the user the choice of canceling, discarding changes, or saving.
			editedCodeFile.canClose(
				withDelegate: self,
				shouldClose: #selector(document(_:shouldClose:contextInfo:)),
				contextInfo: shouldClose
			)
			// pointee becomes false when user select cancel
			guard shouldClose.pointee else {
				break
			}
		}
		 */

		let areAllOpenedCodeFilesClean = editorManager.editorLayout.gatherOpenFiles()
			.compactMap(\.fileDocument)
			.allSatisfy { !$0.isDocumentEdited }
		return areAllOpenedCodeFilesClean
	}
}

struct WorkspaceProxy: ViewModifier {
	@Bindable var model: WorkspaceModel

	func body(content: Content) -> some View {
		content
			.fileImporter(isPresented: $model.isAddToWorkspacePresented, allowedContentTypes: [.item, .folder]) { result in
				switch result {
				case let .success(url):
					model.project.addIfNew(at: url)
				case let .failure(error):
					print(error)
				}
			}
	}
}
