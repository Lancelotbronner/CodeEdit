//
//  SourceControlModel.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/05/20.
//

import Foundation
import AppKit
import OSLog

/// This class is used to perform git functions such as fetch, pull, add/remove of changes, commit, push, etc.
/// It also stores remotes, branches, current changes, stashes, and commits
@Observable
final class RepositoryModel {
    static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "SourceControlManager")

    let gitClient: GitClient

	var url: URL { gitClient.directoryURL }

    /// A list of changed files
    var changedFiles: [GitChangedFile] = []

    /// Current branch
    var currentBranch: GitBranch?

    /// All branches, local and remote
    var branches: [GitBranch] = []

    /// All remotes
    var remotes: [GitRemote] = []

    /// All stashed entries
    var stashEntries: [GitStashEntry] = []

    /// Number of unsynced commits with remote in current branch
    var numberOfUnsyncedCommits: (ahead: Int, behind: Int) = (ahead: 0, behind: 0)

    /// Is project a git repository
    var isGitRepository: Bool = false

    /// Is the push sheet presented
    var pushSheetIsPresented: Bool = false {
        didSet {
            self.operationBranch = nil
            self.operationRebase = false
            self.operationForce = false
            self.operationIncludeTags = false
        }
    }

    /// Is the pull sheet presented
    var pullSheetIsPresented: Bool = false {
        didSet {
            self.operationBranch = nil
            self.operationRebase = false
            self.operationForce = false
            self.operationIncludeTags = false
        }
    }

    /// Is the fetch sheet presented
    var fetchSheetIsPresented: Bool = false

    /// Is the stash sheet presented
    var stashSheetIsPresented: Bool = false

    /// Is the remote sheet presented
    var addExistingRemoteSheetIsPresented: Bool = false

    /// Branch selected for source control operations
    var operationBranch: GitBranch?

    /// Remote selected for source control operations
    var operationRemote: GitRemote?

    /// Rebase boolean set for source control operations
    var operationRebase: Bool = false

    /// Force boolean set for source control operations
    var operationForce: Bool = false

    /// Include tags boolean set for source control operations
    var operationIncludeTags: Bool = false

    /// Branch to switch to
    var switchToBranch: GitBranch?

    /// Is discard all alert presented
    var discardAllAlertIsPresented: Bool = false

    /// Is no changes to stage alert presented
    var noChangesToStageAlertIsPresented: Bool = false

    /// Is no changes to unstage alert presented
    var noChangesToUnstageAlertIsPresented: Bool = false

    /// Is no changes to stash alert presented
    var noChangesToStashAlertIsPresented: Bool = false

    /// Is no changes to discard alert presented
    var noChangesToDiscardAlertIsPresented: Bool = false

    var orderedLocalBranches: [GitBranch] {
        var orderedBranches: [GitBranch] = [currentBranch].compactMap { $0 }
        let otherBranches = branches.filter { $0.isLocal && $0 != currentBranch }
            .sorted { $0.name.lowercased() < $1.name.lowercased() }
        orderedBranches.append(contentsOf: otherBranches)
        return orderedBranches
    }

    init(
		for client: GitClient
    ) {
        gitClient = client
    }

	convenience init(at url: URL) {
		let client = GitClient(directoryURL: url, shellClient: currentWorld.shellClient)
		self.init(for: client)
	}

    /// Show alert for error
    func showAlertForError(title: String, error: Error) async {
        if let error = error as? GitClient.GitClientError {
            await showAlert(title: title, message: error.description)
            return
        }

        if let error = error as? LocalizedError {
            var description = error.errorDescription ?? ""
            if let failureReason = error.failureReason {
                if description.isEmpty {
                    description += failureReason
                } else {
                    description += "\n\n" + failureReason
                }
            }

            if let recoverySuggestion = error.recoverySuggestion {
                if description.isEmpty {
                    description += recoverySuggestion
                } else {
                    description += "\n\n" + recoverySuggestion
                }
            }

            await showAlert(title: title, message: description)
        } else {
            await showAlert(title: title, message: error.localizedDescription)
        }
    }

    private func showAlert(title: String, message: String) async {
        await MainActor.run {
            let alert = NSAlert()
            alert.messageText = title
            alert.informativeText = message
            alert.addButton(withTitle: "OK")
            alert.alertStyle = .warning
            alert.runModal()
        }
    }
}
