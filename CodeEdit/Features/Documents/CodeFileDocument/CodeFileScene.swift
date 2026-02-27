//
//  CodeFileScene.swift
//  CodeEdit
//
//  Created by Christophe Bronner on 2026-02-25.
//

import SwiftUI

struct CodeFileScene: Scene {
	var body: some Scene {
		DocumentGroup {
			CodeFileDocument()
		} editor: { config in
			SettingsInjector {
				WindowCodeFileView(codeFile: config.document)
			}
			.onAppear {
				config.document.fileURL = config.fileURL
			}
		}
	}
}

