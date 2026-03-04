//
//  SourceControlCommands.swift
//  CodeEdit
//
//  Created by Austin Condiff on 6/29/24.
//

import SwiftUI

struct SourceControlCommands: Commands {
	@FocusedValue(WorkspaceModel.self) private var workspace

    @State private var confirmDiscardChanges: Bool = false

    var sourceControlManager: RepositoryModel? {
        workspace?.workspaceRepository
    }

    var body: some Commands {
        CommandMenu("Source Control") {
            Group {
                Button("Commit...") {
                    // TODO: Open Source Control Navigator to Changes tab
                }
                .disabled(true)

                Button("Push...") {
                    sourceControlManager?.pushSheetIsPresented = true
                }

                Button("Pull...") {
                    sourceControlManager?.pullSheetIsPresented = true
                }
                .keyboardShortcut("x", modifiers: [.command, .option])

                Button("Fetch Changes") {
                    sourceControlManager?.fetchSheetIsPresented = true
                }

                Divider()

                Button("Stage All Changes") {
                    guard let sourceControlManager else { return }
                    if sourceControlManager.changedFiles.isEmpty {
                        sourceControlManager.noChangesToStageAlertIsPresented = true
                    } else {
                        Task {
                            do {
                                try await sourceControlManager.add(sourceControlManager.changedFiles.map { $0.fileURL })
                            } catch {
                                await sourceControlManager.showAlertForError(
                                    title: "Failed To Stage Changes",
                                    error: error
                                )
                            }
                        }
                    }
                }

                Button("Unstage All Changes") {
                    guard let sourceControlManager else { return }
                    if sourceControlManager.changedFiles.isEmpty {
                        sourceControlManager.noChangesToUnstageAlertIsPresented = true
                    } else {
                        Task {
                            do {
                                try await sourceControlManager.reset(
                                    sourceControlManager.changedFiles.map { $0.fileURL }
                                )
                            } catch {
                                await sourceControlManager.showAlertForError(
                                    title: "Failed To Unstage Changes",
                                    error: error
                                )
                            }
                        }
                    }
                }

                Divider()

                Button("Cherry-Pick...") {
                    // TODO: Implementation Needed
                }
                .disabled(true)

                Button("Stash Changes...") {
                    if sourceControlManager?.changedFiles.isEmpty ?? false {
                        sourceControlManager?.noChangesToStashAlertIsPresented = true
                    } else {
                        sourceControlManager?.stashSheetIsPresented = true
                    }
                }

                Divider()

                Button("Discard All Changes...") {
                    if sourceControlManager?.changedFiles.isEmpty ?? false {
                        sourceControlManager?.noChangesToDiscardAlertIsPresented = true
                    } else {
                        sourceControlManager?.discardAllAlertIsPresented = true
                    }
                }

                Divider()

                Button("Add Exisiting Remote...") {
                    sourceControlManager?.addExistingRemoteSheetIsPresented = true
                }
            }
            .disabled(workspace == nil)
        }
    }
}
