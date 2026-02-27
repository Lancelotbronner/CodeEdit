//
//  ProjectSettings.swift
//  CodeEdit
//
// Created by Christophe Bronner on 2026-02-25.
//

import SwiftUI

@Observable
final class ProjectSettings {
	init() {}

	var projectName = ""
}

extension ProjectSettings {
	var isEmpty: Bool {
		projectName.isEmpty
	}
}

extension ProjectSettings: Codable {
	private enum CodingKeys: String, CodingKey {
		case _projectName = "projectName"
	}

	/// Explicit decoder init for setting default values when key is not present in `JSON`
	convenience init(from decoder: Decoder) throws {
		self.init()

		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.projectName = try container.decodeIfPresent(String.self, forKey: ._projectName) ?? ""
	}
}
