//
//  ItemUI.swift
//  CodeEdit
//
//  Created by Christophe Bronner on 2026-03-03.
//

import SwiftUI

struct ItemLabel: View {
	let model: ItemModel

	var body: some View {
		Label {
			Text(model.displayName)
		} icon: {
			ItemIcon(model: model)
		}
	}
}

struct ItemCell: View {
	@Bindable var model: ItemModel

	var body: some View {
		Label {
			TextField("Name", text: $model.displayName)
				.foregroundStyle(model.exists ? Color.primary : Color.red)
			//TODO: repository marker
		} icon: {
			ItemIcon(model: model)
		}
		.tag(model)
	}
}

struct ItemIcon: View {
	let model: ItemModel

	var body: some View {
		model.icon
			.foregroundStyle(FileIcon.iconColor(fileType: model.type))
	}
}
