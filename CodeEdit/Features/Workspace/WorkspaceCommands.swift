//
//  OpenWorkspaceOrFile.swift
//  CodeEdit
//
//  Created by Christophe Bronner on 2026-02-25.
//

import SwiftUI

struct WorkspaceCommands: Commands {
	@FocusedValue(WorkspaceModel.self) private var workspace

	var body: some Commands {
		CommandGroup(after: .newItem) {
			let name = workspace?.displayName ?? ""
			Button("Add Files to \"\(name)\"...") {
				workspace?.isAddToWorkspacePresented = true
			}
			.disabled(workspace == nil)
			Button("Open Workspace...") {
				WorkspaceManager.shared.isImporterPresented = true
			}
		}
	}
}

extension FocusedValues {
	@Entry var utilityAreaViewModel: UtilityAreaViewModel?
}
