//
//  GitChangedFileLabel.swift
//  CodeEdit
//
//  Created by Khan Winter on 8/23/24.
//

import SwiftUI

struct GitChangedFileLabel: View {
    @Environment(WorkspaceModel.self) var workspace
	@Environment(RepositoryModel.self) private var sourceControlManager

    let file: GitChangedFile

    var body: some View {
        Label {
            Text(file.fileURL.lastPathComponent.trimmingCharacters(in: .whitespacesAndNewlines))
                .lineLimit(1)
                .truncationMode(.middle)
        } icon: {
            if let ceFile = workspace.workspaceFileManager?.getFile(file.ceFileKey, createIfNotFound: true) {
                Image(nsImage: ceFile.nsIcon)
                    .renderingMode(.template)
            } else {
                Image(systemName: FileIcon.fileIcon(fileType: nil))
                    .renderingMode(.template)
            }
        }
    }
}

/*
#Preview {
    Group {
        GitChangedFileLabel(file: GitChangedFile(
            status: .modified,
            stagedStatus: .none,
            fileURL: URL(filePath: "/Users/CodeEdit/app.jsx"),
            originalFilename: nil
        ))
        .environmentObject(RepositoryModel(at: URL(filePath: "/Users/CodeEdit")))
        .environmentObject(WorkspaceModel())

        GitChangedFileLabel(file: GitChangedFile(
            status: .none,
            stagedStatus: .renamed,
            fileURL: URL(filePath: "/Users/CodeEdit/app.jsx"),
            originalFilename: "app2.jsx"
        ))
        .environmentObject(RepositoryModel(workspaceURL: URL(filePath: "/Users/CodeEdit"), editorManager: .init()))
        .environmentObject(WorkspaceModel())
    }.padding()
}
*/
