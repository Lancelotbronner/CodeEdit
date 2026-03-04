//
//  ProjectList.swift
//  CodeEdit
//
//  Created by Christophe Bronner on 2026-03-03.
//

import SwiftUI

/// A list that functions as a project navigator, showing collapsible folders and files.
///
/// When selecting a file it will open in the editor.
struct ProjectNavigator: View {
	@Environment(WorkspaceModel.self) private var workspace

	var body: some View {
		VStack(spacing: 0) {
			ProjectList(workspace: workspace)
			Divider()
			ProjectFooter(project: workspace.project)
		}
	}
}

private struct ProjectList: View {
	@Bindable var workspace: WorkspaceModel

	var body: some View {
		List(workspace.project.roots, selection: $workspace.project.selected) { item in
			ProjectCell(model: item)
				.listRowSeparator(.hidden)
				.listRowInsets(EdgeInsets())
		}
		.listStyle(.inset)
		.environment(workspace.project)
		.contextMenu(forSelectionType: ItemModel.self) {
			ProjectContextMenu(items: $0)
		} primaryAction: { items in

		}
	}
}

private struct ProjectCell: View {
	@Environment(ProjectManager.self) private var project
	@Bindable var model: ItemModel

	var body: some View {
		Group {
			if let children = model.children {
				DisclosureGroup(isExpanded: $model.isExpanded.animation(.snappy)) {
					ForEach(children.filter(project.contains)) {
						ProjectCell(model: $0)
					}
				} label: {
					ItemCell(model: model)
				}
				//TODO: preview drop just as Xcode does
				.dropDestination(for: URL.self) { items, session in
					for item in items {
						do {
							let dst = model.url.appending(component: item.lastPathComponent)
							if session.suggestedOperations.contains(.copy) {
								try FileManager.default.copyItem(at: item, to: dst)
							} else {
								try FileManager.default.moveItem(at: item, to: dst)
							}
						} catch {
							print("drop", item, "on", model.url, "failed:", error)
						}
					}
				}
			} else {
				ItemCell(model: model)
			}
		}
		.draggable(model.url)
	}
}
