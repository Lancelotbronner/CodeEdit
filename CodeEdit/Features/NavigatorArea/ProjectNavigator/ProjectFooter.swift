//
//  ProjectFooter.swift
//  CodeEdit
//
//  Created by Christophe Bronner on 2026-03-04.
//

import SwiftUI

struct ProjectFooter: View {
	@Environment(\.controlActiveState) private var activeState
	@Environment(\.colorScheme) private var colorScheme
	@Environment(EditorManager.self) private var editorManager
	@Environment(WorkspaceModel.self) private var workspace
	@FocusState private var isFocused
	@Bindable var project: ProjectManager

	var body: some View {
		HStack {
			addNewFileButton
			ControlGroup("Filter Controls") {
				FilterDropDownIconButton(menu: {
					ForEach([(true, "Folders on top"), (false, "Alphabetically")], id: \.0) { value, title in
						Toggle(title, isOn: $project.sortFoldersOnTop)
					}
				}, isOn: !project.query.isEmpty)
				.foregroundStyle(
					project.query.isEmpty
					? Color(.secondaryLabelColor)
					: Color(.controlAccentColor)
				)
				.help("Show files with matching name")

				TextField("Filter", text: $project.query, axis: .horizontal)
					.focused($isFocused)

				if !project.query.isEmpty {
					Button("Clear", systemImage: "xmark.circle.fill") {
						project.query = ""
						isFocused = false
					}
					.disabled(project.query.isEmpty)
				}

				Toggle("Only Recent", systemImage: "clock", isOn: $project.isRecent)
					.help("Show only recent files")

				Toggle("Only Modified", isOn: $project.isModified)
					.help("Show only files with source-control status")
			}
			.controlGroupStyle(TextFieldControlGroupStyle(isFocused: $isFocused))
		}
		.frame(maxWidth: .infinity)
		.padding(8)
	}

	/// Retrieves the active tab URL from the underlying editor instance, if theres no
	/// active tab, fallbacks to the workspace's root directory
	private func activeTabURL() -> URL {
		if let selectedTab = editorManager.activeEditor.selectedTab {
			if selectedTab.file.isFolder {
				return selectedTab.file.url
			}

			// If the current active tab belongs to a file, pop the filename from
			// the path URL to retrieve the folder URL
			let activeTabFileURL = selectedTab.file.url

			if URLComponents(url: activeTabFileURL, resolvingAgainstBaseURL: false) != nil {
				var pathComponents = activeTabFileURL.pathComponents
				pathComponents.removeLast()

				let fileURL = NSURL.fileURL(withPathComponents: pathComponents)! as URL
				return fileURL
			}
		}

		return workspace.workspaceFileManager!.folderUrl
	}

	private var addNewFileButton: some View {
		Menu {
			Button("Add File") {
				let filePathURL = activeTabURL()
				guard let rootFile = workspace.workspaceFileManager?.getFile(filePathURL.path) else { return }
				do {
					if let newFile = try workspace.workspaceFileManager?.addFile(
						fileName: "untitled",
						toFile: rootFile
					) {
						workspace.listenerModel.highlightedFileItem = newFile
						workspace.editorManager.openTab(item: newFile)
					}
				} catch {
					let alert = NSAlert(error: error)
					alert.addButton(withTitle: "Dismiss")
					alert.runModal()
				}
			}

			Button("Add Folder") {
				let filePathURL = activeTabURL()
				guard let rootFile = workspace.workspaceFileManager?.getFile(filePathURL.path) else { return }
				do {
					if let newFolder = try workspace.workspaceFileManager?.addFolder(
						folderName: "untitled",
						toFile: rootFile
					) {
						workspace.listenerModel.highlightedFileItem = newFolder
					}
				} catch {
					let alert = NSAlert(error: error)
					alert.addButton(withTitle: "Dismiss")
					alert.runModal()
				}
			}
		} label: {}
		.background {
			Image(systemName: "plus")
				.accessibilityHidden(true)
		}
		.menuStyle(.borderlessButton)
		.menuIndicator(.hidden)
		.frame(maxWidth: 18, alignment: .center)
		.opacity(activeState == .inactive ? 0.45 : 1)
		.accessibilityLabel("Add Folder or File")
		.accessibilityIdentifier("addButton")
	}
}

struct FilterDropDownIconButton<MenuView: View>: View {
	@Environment(\.controlActiveState)
	private var activeState

	var menu: () -> MenuView

	var isOn: Bool?

	var body: some View {
		Menu { menu() } label: {}
			.background {
				if isOn == true {
					Image(ImageResource.line3HorizontalDecreaseChevronFilled)
						.foregroundStyle(.tint)
				} else {
					Image(ImageResource.line3HorizontalDecreaseChevron)
				}
			}
			.menuStyle(.borderlessButton)
			.menuIndicator(.hidden)
			.frame(width: 26, height: 13)
			.clipShape(.rect(cornerRadius: 6.5))
	}
}

