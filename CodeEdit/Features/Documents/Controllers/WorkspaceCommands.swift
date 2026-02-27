//
//  OpenWorkspaceOrFile.swift
//  CodeEdit
//
//  Created by Christophe Bronner on 2026-02-25.
//

import SwiftUI

struct WorkspaceCommands: Commands {
	var body: some Commands {
		CommandGroup(replacing: .newItem) {
			Button("Open...", systemImage: "") {
				WorkspaceManager.shared.isImporterPresented = true
			}
		}
	}
}

extension FocusedValues {
	@Entry var workspace: WorkspaceModel?
	@Entry var utilityAreaViewModel: UtilityAreaViewModel?
}
