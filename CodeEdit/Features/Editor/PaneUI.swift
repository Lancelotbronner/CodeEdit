//
//  PaneUI.swift
//  CodeEdit
//
//  Created by Christophe Bronner on 2026-03-10.
//

import SwiftUI

struct PaneContentView: View {
	let model: PaneModel
	let manager: EditorManager2

	var body: some View {
		VStack {
			if !manager.isSingleTab {
				PaneTabs()
			}
			PaneBar()
			//TODO: language-specific scope headers
			//TODO: Source Editor
		}
	}
}

private struct PaneTabs: View {
	var body: some View {
		Button("Close Pane", systemImage: "xmark") {

		}
		Button("Focus Pane", systemImage: "arrow.down.left.and.arrow.up.right") {

		}
		Picker("Tabs", selection: .constant(0)) {

		}
		Menu("Add Tab or Pane", systemImage: "plus") {
			Button("Tab") {

			}
			Divider()
			Button("Pane on the Right") {}
			Button("Pane Below") {}
		}
	}
}

private struct PaneBar: View {
	var body: some View {
		Menu("Related Items") {}
		//TODO: these are pane-specific, navigator selection also switches with the location
		Button("Previous Location") {}
		Button("Next Location") {}
		//TODO: Path to selected item in tab
		Button("Show Previous Issue") {}
		Menu("Issues") {}
		Button("Show Next Issue") {}
		Toggle("Code Review", isOn: .constant(false))
		Menu("Editor Options") {}
	}
}
