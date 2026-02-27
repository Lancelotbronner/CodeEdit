//
//  CodeEditApp.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 11/03/2023.
//

import SwiftUI
import WelcomeWindow
import AboutWindow

@main
struct CodeEditApp: App {
	@NSApplicationDelegateAdaptor var appdelegate: AppDelegate
	@ObservedObject var settings = Settings.shared

	let updater = SoftwareUpdater()

	init() {
		// Register singleton services before anything else
		ServiceContainer.register(
			LSPService()
		)

		NSMenuItem.swizzle()
		NSSplitViewItem.swizzle()
	}

	var body: some Scene {
		Group {
			WelcomeWindow(
				subtitleView: { WelcomeSubtitleView() },
				actions: { dismissWindow in
					NewFileButton()
					GitCloneButton()
					WelcomeButton(
						iconName: "folder",
						title: "Open File or Folder..."
					) {
						WorkspaceManager.shared.isImporterPresented = true
					}
				},
				onDrop: { url, dismissWindow in
					Task {
						await WorkspaceManager.shared.open(at: url)
						dismissWindow()
					}
				}
			)

			WorkspaceScene()
			ExtensionManagerWindow()

			AboutWindow(
				subtitleView: { AboutSubtitleView() },
				actions: {
					AboutButton(title: "Contributors", destination: {
						ContributorsView()
					})
					AboutButton(title: "Acknowledgements", destination: {
						AcknowledgementsView()
					})
				},
				footer: { AboutFooterView() }
			)

			SettingsWindow()
				.commands {
					CodeEditCommands()
				}
		}
		.environment(\.settings, settings.preferences) // Add settings to each window environment
	}
}
