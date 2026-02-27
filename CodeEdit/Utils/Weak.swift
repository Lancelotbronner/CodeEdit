//
//  Weak.swift
//  CodeEdit
//
//  Created by Christophe Bronner on 2026-02-26.
//

@propertyWrapper
public struct Weak<T: AnyObject> {
	public weak let wrappedValue: T?

	public init(_ wrappedValue: T?) {
		self.wrappedValue = wrappedValue
	}
}
