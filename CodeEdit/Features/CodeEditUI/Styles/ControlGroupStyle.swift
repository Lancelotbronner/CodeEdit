//
//  ControlGroupStyle.swift
//  CodeEdit
//
//  Created by Christophe Bronner on 2026-03-04.
//

import SwiftUI

struct TextFieldControlGroupStyle: ControlGroupStyle {
	@Environment(\.appearsActive) private var appearsActive
	@FocusState.Binding var isFocused: Bool

	func makeBody(configuration: Configuration) -> some View {
		HStack(alignment: .center) {
			configuration.content
		}
		.buttonStyle(.borderless)
		.labelStyle(.iconOnly)
		.textFieldStyle(.plain)
		.toggleStyle(.button)
		.padding(.horizontal, 8)
		.padding(.vertical, 4)
		.background {
			let fillColor = color(
				focusedActive: Color(red: 0.118, green: 0.118, blue: 0.118),
				focusedInactive: Color(red: 0.118, green: 0.118, blue: 0.118),
				active: Color(red: 0.196, green: 0.196, blue: 0.196),
				inactive: Color(red: 0.118, green: 0.118, blue: 0.118))
			let strokeColor = color(
				focusedActive: Color(red: 0.209, green: 0.209, blue: 0.209),
				focusedInactive: Color(red: 0.163, green: 0.163, blue: 0.163),
				active: Color(red: 0.234, green: 0.234, blue: 0.234),
				inactive: Color(red: 0.163, green: 0.163, blue: 0.163))
			Capsule()
				.stroke(strokeColor, lineWidth: 1.25)
				.fill(fillColor)
		}
		.onTapGesture {
			isFocused = true
		}
	}

	private func color(
		focusedActive: Color,
		focusedInactive: Color,
		active: Color,
		inactive: Color,
	) -> Color {
		switch (isFocused, appearsActive) {
		case (false, false): inactive
		case (false, true): active
		case (true, false): focusedInactive
		case (true, true): focusedActive
		}
	}
}

#Preview {
	@Previewable @State var text = ""
	@Previewable @FocusState var isFocused
	VStack {
		ControlGroup("Project Toolbar") {
			Menu("Menu") {}
			TextField("Filter", text: $text)
				.focused($isFocused)
			if !text.isEmpty {
				Button("Clear") {
					text = ""
					isFocused = false
				}
			}
			Button("Only Recents") {}
			Button("Only Modified") {}
		}
		.controlGroupStyle(TextFieldControlGroupStyle(isFocused: $isFocused))
		TextField("Focus Away", text: .constant(""))
			.textFieldStyle(.plain)
	}
	.padding()
	.background(.black)
}
