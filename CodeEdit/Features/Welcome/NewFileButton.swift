//
//  NewFileButton.swift
//  CodeEdit
//
//  Created by Giorgi Tchelidze on 07.06.25.
//

import SwiftUI
import WelcomeWindow

struct NewFileButton: View {
	@Environment(\.newDocument) private var newDocument
	@Environment(\.dismissWindow) private var dismissWindow

    var body: some View {
        WelcomeButton(
            iconName: "plus.square",
            title: "Create New File...",
            action: {
				newDocument(contentType: .text)
				dismissWindow()
            }
        )
    }
}
