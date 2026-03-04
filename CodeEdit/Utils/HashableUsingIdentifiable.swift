//
//  HashableUsingIdentifiable.swift
//  CodeEdit
//
//  Created by Christophe Bronner on 2026-03-03.
//

public protocol HashableUsingIdentifiable: Hashable, Identifiable {}

public extension HashableUsingIdentifiable {
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}

	static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.id == rhs.id
	}
}
