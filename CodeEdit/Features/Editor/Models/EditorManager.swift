//
//  TabManager.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 03/03/2023.
//

import Combine
import Foundation
import DequeModule
import os

@Observable
final class EditorManager {
    static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "EditorManager")

    /// The complete editor layout.
    var editorLayout: EditorLayout

    var isFocusingActiveEditor = false

    /// The Editor with active focus.
    var activeEditor: Editor {
        didSet {
            activeEditorHistory.prepend(Weak(oldValue))
        }
    }

    /// History of last-used editors.
    var activeEditorHistory: Deque<Weak<Editor>> = []

	var tabBarTabId: Editor.Tab? {
		activeEditor.selectedTab
	}

    // This caching mechanism is a temporary solution and is not optimized
    var updateCachedFlattenedEditors: Bool = true

	@ObservationIgnored
    var cachedFlettenedEditors: [Editor] = []

    var flattenedEditors: [Editor] {
        if updateCachedFlattenedEditors {
            cachedFlettenedEditors = self.getFlattened()
            updateCachedFlattenedEditors = false
        }
        return cachedFlettenedEditors
    }

    // MARK: - Init

    init() {
        let tab = Editor()
		editorLayout = .horizontal(.init(.horizontal, editorLayouts: [.one(tab)]))
        activeEditor = tab
        activeEditorHistory.prepend(Weak(tab))
        isFocusingActiveEditor = false
    }

    /// Initializes the editor manager's state to the "initial" state.
    ///
    /// Functionally identical to the initializer for this class.
    func initCleanState() {
        let tab = Editor()
        self.activeEditor = tab
        self.activeEditorHistory.prepend(Weak(tab))
        self.editorLayout = .horizontal(.init(.horizontal, editorLayouts: [.one(tab)]))
        self.isFocusingActiveEditor = false
    }

    /// Flattens the splitviews.
    func flatten() {
        switch editorLayout {
        case .horizontal(let data), .vertical(let data):
            data.flatten()
        default:
            break
        }
    }

    /// Returns and array of flattened splitviews.
    func getFlattened() -> [Editor] {
        switch editorLayout {
        case .horizontal(let data), .vertical(let data):
            return data.getFlattened()
        default:
            return []
        }
    }

    /// Opens a new tab in a editor.
    /// - Parameters:
    ///   - item: The tab to open.
    ///   - editor: The editor to add the tab to. If nil, it is added to the active tab group.
    ///   - asTemporary: Indicates whether the tab should be opened as a temporary tab or a permanent tab.
    func openTab(item: CEWorkspaceFile, in editor: Editor? = nil, asTemporary: Bool = false) {
        let editor = editor ?? activeEditor
        editor.openTab(file: item, asTemporary: asTemporary)
    }

    // MARK: - Close Editor

    /// Close an editor and fix editor manager state, updating active editor, etc.
    /// - Parameter editor: The editor to close
    func closeEditor(_ editor: Editor) {
        editor.close()
        if activeEditor == editor {
            setNewActiveEditor(excluding: editor)
        }

        flatten()
        updateCachedFlattenedEditors = true
    }

    /// Set a new active editor.
    /// - Parameter editor: The editor to exclude.
    func setNewActiveEditor(excluding editor: Editor) {
		activeEditorHistory.removeAll { $0.wrappedValue == nil || $0.wrappedValue == editor }
        if activeEditorHistory.isEmpty {
            activeEditor = findSomeEditor(excluding: editor)
        } else {
			activeEditor = activeEditorHistory.removeFirst().wrappedValue!
        }
    }

    /// Find some editor, or if one cannot be found set up the editor manager with a clean state.
    /// - Parameter editor: The editor to exclude.
    /// - Returns: Some editor, order is not guaranteed.
    func findSomeEditor(excluding editor: Editor) -> Editor {
        guard let someEditor = editorLayout.findSomeEditor(except: editor) else {
            initCleanState()
            return activeEditor
        }
        return someEditor
    }

    // MARK: - Focus

    func toggleFocusingEditor(from editor: Editor) {
        if !isFocusingActiveEditor {
            activeEditor = editor
        }
        isFocusingActiveEditor.toggle()
    }
}
