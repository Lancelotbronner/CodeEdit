//
//  TabUI.swift
//  CodeEdit
//
//  Created by Christophe Bronner on 2026-03-10.
//

import SwiftUI

struct TabContentView: View {
	let model: TabModel

	var body: some View {
		if let item = model.item {
			Text("Editor for \(item.url)")
		} else {
			Text("Open quickly")
		}
	}
}
