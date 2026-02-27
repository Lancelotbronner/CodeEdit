//
//  CEWorkspaceSettingsManager.swift
//  CodeEdit
//
//  Created by Axel Martinez on 27/3/24.
//

import SwiftUI
import Combine

/// The CodeEdit workspace settings model.
@Observable
final class WorkspaceSettingsManager {
    public var settings: WorkspaceSettings = .init()

    private var storeTask: AnyCancellable?
    private let fileManager = FileManager.default

    private(set) var folderURL: URL

    var settingsURL: URL {
        folderURL.appending(path: "settings").appendingPathExtension("json")
    }

    init(workspaceURL: URL) {
        folderURL = workspaceURL.appending(path: ".codeedit", directoryHint: .isDirectory)
        loadSettings()

		withContinuousObservationTracking { [weak self] in
			try? self?.savePreferences()
		}
		//TODO: reimplement throttle
		/*
        storeTask = $settings
            .receive(on: DispatchQueue.main)
            .throttle(for: 2.0, scheduler: RunLoop.main, latest: true)
            .sink { _ in
                try? self.savePreferences()
            }
		 */
    }

    func cleanUp() {
        storeTask?.cancel()
        storeTask = nil
    }

    deinit {
        cleanUp()
    }

    /// Load and construct ``CEWorkspaceSettings`` model from `.codeedit/settings.json`
    private func loadSettings() {
        guard fileManager.fileExists(atPath: settingsURL.path),
              let json = try? Data(contentsOf: settingsURL),
              let prefs = try? JSONDecoder().decode(WorkspaceSettings.self, from: json)
        else { return }
        self.settings = prefs
    }

    /// Save``CEWorkspaceSettingsManager`` model to `.codeedit/settings.json`
    func savePreferences() throws {
        // If the user doesn't have any settings to save, don't save them.
        guard !settings.isEmpty else {
            // Settings is empty, remove the file & directory if it's empty.
            if fileManager.fileExists(atPath: settingsURL.path()) {
                try fileManager.removeItem(at: settingsURL)

                if try fileManager.contentsOfDirectory(atPath: folderURL.path()).isEmpty {
                    try fileManager.removeItem(at: folderURL)
                }
            }
            return
        }

        if !fileManager.fileExists(atPath: folderURL.path()) {
            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
        }

        let data = try JSONEncoder().encode(settings)
        let json = try JSONSerialization.jsonObject(with: data)
        let prettyJSON = try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
        try prettyJSON.write(to: settingsURL, options: .atomic)
    }
}
