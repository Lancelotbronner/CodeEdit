//
//  HistoryInspectorView.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/03/24.
//
import SwiftUI

struct HistoryInspectorView: View {
    @AppSettings(\.sourceControl.git.showMergeCommitsPerFileLog)
    var showMergeCommitsPerFileLog

    @Environment(WorkspaceModel.self) var workspace

    @Environment(EditorManager.self) private var editorManager

    @ObservedObject private var model: HistoryInspectorModel

    @State var selection: GitCommit?

    /// Initialize with GitClient
    /// - Parameter gitClient: a GitClient
    init() {
        self.model = .init()
    }

    var body: some View {
        Group {
			VStack {
				if model.commitHistory.isEmpty {
					CEContentUnavailableView("No History")
				} else {
					List(selection: $selection) {
						ForEach(model.commitHistory) { commit in
							HistoryInspectorItemView(commit: commit, selection: $selection)
								.tag(commit)
								.listRowSeparator(.hidden)
						}
					}
				}
			}
		}
        .onReceive(editorManager.activeEditor.objectWillChange) { _ in
            Task {
                await model.setFile(url: editorManager.activeEditor.selectedTab?.file.url.path())
            }
        }
        .onChange(of: editorManager.activeEditor) { _, _ in
            Task {
                await model.setFile(url: editorManager.activeEditor.selectedTab?.file.url.path())
            }
        }
        .onChange(of: editorManager.activeEditor.selectedTab) { _, _ in
            Task {
                await model.setFile(url: editorManager.activeEditor.selectedTab?.file.url.path())
            }
        }
        .task {
            await model.setWorkspace(sourceControlManager: workspace.workspaceRepository)
            await model.setFile(url: editorManager.activeEditor.selectedTab?.file.url.path)
        }
        .onChange(of: showMergeCommitsPerFileLog) { _, _ in
            Task {
                await model.updateCommitHistory()
            }
        }
    }
}
