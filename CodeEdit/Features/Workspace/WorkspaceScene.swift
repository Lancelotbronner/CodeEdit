//
//  WorkspaceScene.swift
//  CodeEdit
//
//  Created by Christophe Bronner on 2026-02-25.
//

import SwiftUI

struct WorkspaceScene: Scene {
	var body: some Scene {
		DocumentGroup {
			WorkspaceDocument()
		} editor: { config in
			WorkspaceContentView(workspace: config.document.model)
				.task {
					do {
						try await config.document.load(using: config)
					} catch {
						print("Failed to open workspace: \(error)")
					}
				}
		}
		.commands {
			WorkspaceCommands()
		}
	}
}

private struct WorkspaceContentView: View {
	@State private var navigator = NavigatorAreaViewModel()
	@State private var inspector = InspectorAreaViewModel()
	@State var quickOpenPanel: SearchPanel?
	@State var commandPalettePanel: SearchPanel?
	@State private var isInspectorPresented = false
	@State private var isToolbarPresented = false
	let workspace: WorkspaceModel

	var body: some View {
		SettingsInjector {
			NavigationSplitView {
				NavigatorAreaView(workspace: workspace, viewModel: navigator)
					.frame(minWidth: 300)
			} detail: {
				WindowObserver {
					WorkspaceView(utilityAreaViewModel: workspace.utilityAreaModel)
				}
			}
			.inspector(isPresented: $isInspectorPresented) {
				InspectorAreaView(viewModel: inspector)
			}
			.onAppear {
				CommandManager.shared.addCommand(
					name: "Quick Open",
					title: "Quick Open",
					id: "quick_open") {

					}
				CommandManager.shared.addCommand(
					name: "Toggle Navigator",
					title: "Toggle Navigator",
					id: "toggle_left_sidebar") {
						//TODO: Toggle Navigator
					}
				CommandManager.shared.addCommand(
					name: "Toggle Inspector",
					title: "Toggle Inspector",
					id: "toggle_right_sidebar") {
						isInspectorPresented.toggle()
					}
			}
			.toolbar {
				TasksToolbar(workspace)
				ToolbarItem(id: ".branchPicker", placement: .navigation) {
					ToolbarBranchPicker(workspaceFileManager: workspace.workspaceFileManager)
				}
				ToolbarItem(id: ".activityViewer", placement: .status) {
					ActivityViewer(
						workspaceFileManager: workspace.workspaceFileManager,
						workspaceSettingsManager: workspace.workspaceSettingsManager,
						taskNotificationHandler: workspace.taskNotificationHandler,
						taskManager: workspace.taskManager)
				}
				if #available(macOS 26.0, *) {
					ToolbarSpacer(.fixed, placement: .status)
				} else {
					ToolbarItem(placement: .status) {}
				}
				ToolbarItem(id: ".notificationItem", placement: .status) {
					NotificationToolbarItem()
				}
			}
			.modifier(WorkspaceManagerProxy())
			.modifier(WorkspaceProxy(model: workspace))
			.environment(workspace)
			.environment(navigator)
			.environment(workspace.editorManager)
			.environmentObject(workspace.statusBarViewModel)
			.environmentObject(workspace.undoRegistration)
			.environment(workspace.utilityAreaModel)
			.environment(workspace.taskManager)
			.focusedValue(workspace)
		}
	}

//	private func toggleToolbarPresented() {
//		if toolbarCollapsed {
//			window?.titleVisibility = .visible
//			window?.title = workspace?.workspaceFileManager?.folderUrl.lastPathComponent ?? "Empty"
//			window?.toolbar = nil
//		} else {
//			window?.titleVisibility = .hidden
//			setupToolbar()
//		}
	}

	/*
	// Listen to changes in all tabs/files
	internal func listenToDocumentEdited(workspace: WorkspaceModel) {
		workspace.editorManager?.$activeEditor
			.flatMap({ editor in
				editor.$tabs
			})
			.compactMap({ tab in
				Publishers.MergeMany(tab.elements.compactMap({ $0.file.fileDocumentPublisher }))
			})
			.switchToLatest()
			.compactMap({ fileDocument in
				fileDocument?.isDocumentEditedPublisher
			})
			.flatMap({ $0 })
			.sink { isDocumentEdited in
				if isDocumentEdited {
					self.setDocumentEdited(true)
					return
				}

				self.updateDocumentEdited(workspace: workspace)
			}
			.store(in: &cancellables)

		// Listen to change of tabs, if closed tab without saving content,
		// we also need to recalculate isDocumentEdited
		workspace.editorManager?.$activeEditor
			.flatMap({ editor in
				editor.$tabs
			})
			.sink { _ in
				self.updateDocumentEdited(workspace: workspace)
			}
			.store(in: &cancellables)
	}

	// Recalculate documentEdited by checking if any tab/file is edited
	private func updateDocumentEdited(workspace: WorkspaceModel) {
		let hasEditedDocuments = !(workspace
			.editorManager?
			.editorLayout
			.gatherOpenFiles()
			.filter({ $0.fileDocument?.isDocumentEdited == true })
			.isEmpty ?? true)
		self.setDocumentEdited(hasEditedDocuments)
	}

		private func openQuickly() {

		}
	}
	 */

	/*
	 private func getSelectedCodeFile() -> CodeFileDocument? {
		 workspace?.editorManager?.activeEditor.selectedTab?.file.fileDocument
	 }

	 @IBAction func saveDocument(_ sender: Any) {
		 guard let codeFile = getSelectedCodeFile() else { return }
		 codeFile.save(sender)
		 workspace?.editorManager?.activeEditor.temporaryTab = nil
	 }

	 @IBAction func openCommandPalette(_ sender: Any) {
		 if let workspace, let state = workspace.commandsPaletteState {
			 if let commandPalettePanel {
				 if commandPalettePanel.isKeyWindow {
					 commandPalettePanel.close()
					 self.panelOpen = false
					 state.reset()
					 return
				 } else {
					 state.reset()
					 window?.addChildWindow(commandPalettePanel, ordered: .above)
					 commandPalettePanel.makeKeyAndOrderFront(self)
					 self.panelOpen = true
				 }
			 } else {
				 let panel = SearchPanel()
				 self.commandPalettePanel = panel
				 let contentView = QuickActionsView(state: state) {
					 panel.close()
					 self.panelOpen = false
				 }
				 panel.contentView = NSHostingView(rootView: SettingsInjector { contentView })
				 window?.addChildWindow(panel, ordered: .above)
				 panel.makeKeyAndOrderFront(self)
				 self.panelOpen = true
			 }
		 }
	 }

	 /// Opens the search navigator and focuses the search field
	 @IBAction func openSearchNavigator(_ sender: Any? = nil) {
		 if navigatorCollapsed {
			 toggleFirstPanel()
		 }

		 if let navigatorViewModel = navigatorSidebarViewModel,
			let searchTab = navigatorViewModel.tabItems.first(where: { $0 == .search }) {
			 DispatchQueue.main.async {
				 self.workspace?.searchState?.shouldFocusSearchField = true
				 navigatorViewModel.setNavigatorTab(tab: searchTab)
			 }
		 }
	 }

	 @IBAction func openQuickly(_ sender: Any?) {
		 if let workspace, let state = workspace.openQuicklyViewModel {
			 if let quickOpenPanel {
				 if quickOpenPanel.isKeyWindow {
					 quickOpenPanel.close()
					 self.panelOpen = false
					 return
				 } else {
					 window?.addChildWindow(quickOpenPanel, ordered: .above)
					 quickOpenPanel.makeKeyAndOrderFront(self)
					 self.panelOpen = true
				 }
			 } else {
				 let panel = SearchPanel()
				 self.quickOpenPanel = panel

				 let contentView = OpenQuicklyView(state: state) {
					 panel.close()
					 self.panelOpen = false
				 } openFile: { file in
					 workspace.editorManager?.openTab(item: file)
				 }.environmentObject(workspace)

				 panel.contentView = NSHostingView(rootView: SettingsInjector { contentView })
				 window?.addChildWindow(panel, ordered: .above)
				 panel.makeKeyAndOrderFront(self)
				 self.panelOpen = true
			 }
		 }
	 }

	 @IBAction func closeCurrentTab(_ sender: Any) {
		 if self.panelOpen { return }
		 if (workspace?.editorManager?.activeEditor.tabs ?? []).isEmpty {
			 self.closeActiveEditor(self)
		 } else {
			 workspace?.editorManager?.activeEditor.closeSelectedTab()
		 }
	 }

	 @IBAction func closeActiveEditor(_ sender: Any) {
		 if workspace?.editorManager?.editorLayout.findSomeEditor(
			 except: workspace?.editorManager?.activeEditor
		 ) == nil {
			 NSApp.sendAction(#selector(NSWindow.performClose(_:)), to: NSApp.keyWindow, from: nil)
		 } else {
			 workspace?.editorManager?.activeEditor.close()
		 }
	 }

	 @IBAction func openWorkspaceSettings(_ sender: Any) {
	 guard let window = window,
			  let workspace = workspace,
			  let workspaceSettingsManager = workspace.workspaceSettingsManager,
			  let taskManager = workspace.taskManager
		else { return }

		if let workspaceSettingsWindow, workspaceSettingsWindow.isVisible {
			workspaceSettingsWindow.makeKeyAndOrderFront(self)
		} else {
			let settingsWindow = NSWindow()
			self.workspaceSettingsWindow = settingsWindow
			let contentView = CEWorkspaceSettingsView(
				dismiss: { [weak self, weak settingsWindow] in
					guard let settingsWindow else { return }
					self?.window?.endSheet(settingsWindow)
				}
			)
				.environmentObject(workspaceSettingsManager)
				.environmentObject(workspace)
				.environment(taskManager)

			settingsWindow.contentView = NSHostingView(rootView: contentView)
			settingsWindow.titlebarAppearsTransparent = true
			settingsWindow.setContentSize(NSSize(width: 515, height: 515))
			settingsWindow.setAccessibilityTitle("Workspace Settings")

			window.beginSheet(settingsWindow, completionHandler: nil)
		}
	 */
