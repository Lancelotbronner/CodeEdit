//
//  FileCommands.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 13/03/2023.
//

import SwiftUI

struct FileCommands: Commands {
    static let recentProjectsMenu = RecentProjectsMenu()

    @Environment(\.openWindow) private var openWindow
	@FocusedValue(\.workspace) private var workspace
	@FocusedValue(\.utilityAreaViewModel) private var utilityAreaViewModel

    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Group {
                Button("New") {
                    NSDocumentController.shared.newDocument(nil)
                }
                .keyboardShortcut("n")

                Button("Open...") {
                    NSDocumentController.shared.openDocument(nil)
                }
                .keyboardShortcut("o")

                // Leave this empty, is done through a hidden API in WindowCommands/Utils/CommandsFixes.swift
                // We set this with a custom NSMenu. See WindowCommands/Utils/RecentProjectsMenu.swift
                Menu("Open Recent") { }

                Button("Open Quickly") {
					//TODO: reimplement Open Quickly
//                    NSApp.sendAction(#selector(CodeEditWindowController.openQuickly(_:)), to: nil, from: nil)
                }
                .keyboardShortcut("o", modifiers: [.command, .shift])
            }
        }

        CommandGroup(replacing: .saveItem) {
            Button("Close Tab") {
				//TODO: reimplement Close Tab
//                if NSApp.target(forAction: #selector(CodeEditWindowController.closeCurrentTab(_:))) != nil {
//                    NSApp.sendAction(#selector(CodeEditWindowController.closeCurrentTab(_:)), to: nil, from: nil)
//                } else {
//                    NSApp.sendAction(#selector(NSWindow.performClose(_:)), to: NSApp.keyWindow, from: nil)
//                }
            }
            .keyboardShortcut("w")

            Button("Close Editor") {
				//TODO: reimplement Close Editor
//                if NSApp.target(forAction: #selector(CodeEditWindowController.closeActiveEditor(_:))) != nil {
//                    NSApp.sendAction(
//                        #selector(CodeEditWindowController.closeActiveEditor(_:)),
//                        to: nil,
//                        from: nil
//                    )
//                } else {
//                    NSApp.sendAction(#selector(NSWindow.performClose(_:)), to: NSApp.keyWindow, from: nil)
//                }
            }
            .keyboardShortcut("w", modifiers: [.control, .shift, .command])

            Button("Close Window") {
                NSApp.sendAction(#selector(NSWindow.performClose(_:)), to: NSApp.keyWindow, from: nil)
            }
            .keyboardShortcut("w", modifiers: [.shift, .command])

            Button("Close Workspace") {
                NSApp.sendAction(#selector(NSWindow.performClose(_:)), to: NSApp.keyWindow, from: nil)
            }
            .keyboardShortcut("w", modifiers: [.control, .option, .command])
            .disabled(workspace == nil)

			if let utilityAreaViewModel {
                Button("Close Terminal") {
                    utilityAreaViewModel.removeTerminals(utilityAreaViewModel.selectedTerminals)
                }
                .keyboardShortcut(.delete)
            }

            Divider()

            Button("Workspace Settings") {
				openWindow(sceneID: .workspaceSettings)
            }
            .disabled(workspace == nil)

            Divider()

            Button("Save") {
				//TODO: reimplement Save
//                NSApp.sendAction(#selector(CodeEditWindowController.saveDocument(_:)), to: nil, from: nil)
            }
            .keyboardShortcut("s")
        }
    }
}
