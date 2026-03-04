//
//  ProjectContextMenu.swift
//  CodeEdit
//
//  Created by Christophe Bronner on 2026-03-04.
//

import SwiftUI

struct ProjectContextMenu: View {
	let items: Set<ItemModel>

	var body: some View {
		let allDirectories = items.allSatisfy(\.isDirectory)
		let allFiles = items.allSatisfy(\.isRegularFile)
		let containsFile = items.contains(where: \.isRegularFile)
		let containsDirectory = items.contains(where: \.isDirectory)
		let isMixed = containsFile && containsDirectory
		//TODO: some of these aren't about being mixed but about the directory level (ie. are they in sme dir or different)

		// Finder
		Button("Show in Finder", systemImage: "finder") {}
		Divider()

		// Open
		Button("Open \(items.count) in New Tab") {}
		if containsFile {
			Button("Open \(items.count) in New Window") {}
		}
		Button("Open with External Editor") {}
		if allFiles {
			Picker("Open As", selection: .constant("source code")) {
				Text("Source Code")
					.tag("source code")
				Divider()
				Text("Hex")
				Text("Quick Look")
				//TODO: other views
				Divider()
				Picker("Always Use", selection: .constant("default")) {
					Text("Source Code")
					Divider()
					Text("Hex")
					Text("Quick Look")
					//TODO: other views
					Divider()
					Text("default")
				}
			}
		}
		Divider()

		// Path
		Button("Copy Path") {}
		Button("Copy Relative Path") {}
		Divider()

		// Inspect
		Button("Show File Inspector") {}
		Divider()

		// New File
		if !isMixed {
			Button("New Empty File") {}
			Button("New File from Clipboard") {}
		}
		Button("New File from Template...") {}
		Divider()

		// Add
		if !isMixed {
			//TODO: reuse button from commands
			Button("Add Files to Workspace") {}
		}
		Button("Add Package Dependencies") {}
		Divider()

		// Delete
		Button("Move to Trash") {}
			.modifierKeyAlternate(.control) {
				Button("Delete Immediately...") {}
			}
		Divider()

		// New Folder
		if !isMixed {
			Button("New Folder") {}
			Button("New Folder from Selection") {}
			Divider()
		}

		// Bookmarks
		//TODO: variant for single item
		Button("Bookmark \(items.count)") {}
			.modifierKeyAlternate(.control) {
				Button("Bookmark \(items.count)...") {}
			}
		Divider()

		// Find
		Button("Find in Selection...") {}

		// Source Control
		Menu("Source Control") {

		}

		// Help
		// Services
	}
}

