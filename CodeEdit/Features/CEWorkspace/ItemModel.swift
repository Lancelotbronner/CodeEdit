//
//  ItemModel.swift
//  CodeEdit
//
//  Created by Christophe Bronner on 2026-03-03.
//

import SwiftUI
import UniformTypeIdentifiers

@Observable @MainActor
final class ItemModel: @MainActor HashableUsingIdentifiable, @MainActor Comparable {
	private static var cache: [String: Weak<ItemModel>] = [:]

	private init(at url: URL, parent: ItemModel?) {
		self.url = url
		name = url.lastPathComponent
		absolutePath = url.absoluteURL.path(percentEncoded: false)
		self.parent = parent
		_displayName = name
		_ = url.startAccessingSecurityScopedResource()
		reloadResourceValues()
		// If we're a root, start monitoring
		guard parent == nil else { return }
	}

	deinit {
		url.stopAccessingSecurityScopedResource()
	}

	/// The URL of the item
	let url: URL
	/// The name of the file
	let name: String
	let absolutePath: String

	var isExpanded = false

	private(set) var contentType: UTType?
	private(set) var exists = true
	private(set) var isRegularFile = false
	private(set) var isDirectory = false

	private var _displayName: String
	private weak var parent: ItemModel?
	private var childrenCache: [ItemModel]??
	private var _monitor: DirectoryEventStream?
}

extension ItemModel {
	static func child(at url: URL, parent: ItemModel?) -> ItemModel {
		let absolutePath = url.absoluteURL.path(percentEncoded: false)
		if let cached = cache[absolutePath]?.wrappedValue {
			return cached
		}
		let item = ItemModel(at: url, parent: parent)
		cache[absolutePath] = Weak(item)
		if parent == nil {
			item.monitor(at: absolutePath)
		}
		return item
	}

	static func root(at url: URL) -> ItemModel {
		child(at: url, parent: nil)
	}

	func monitor(at path: String) {
		guard _monitor == nil else { return }
		_monitor = DirectoryEventStream(directory: path) { [weak self] batch in
			for ev in batch {
				self?.receive(ev)
			}
		}
	}

	private func receive(_ event: DirectoryEventStream.Event) {
		switch event.eventType {
		case .changeInDirectory, .itemChangedOwner, .itemModified:
			// can be ignored as the navigator doesn't care
			return
		case .rootChanged:
			withAnimation {
				exists = FileManager.default.fileExists(atPath: absolutePath)
				childrenCache = nil
			}
		case .itemRenamed where !exists && absolutePath.dropLast() == event.path:
			// special case: re-instate the root
			withAnimation {
				childrenCache = nil
				exists = true
			}
		case .itemCreated, .itemCloned, .itemRemoved, .itemRenamed:
			// update our resource values
			if let item = Self.cache[event.path]?.wrappedValue {
				item.reloadResourceValues()
			}
			// clear the parent's cache
			let parentPath = URL(filePath: event.path)
				.deletingLastPathComponent()
				.absoluteURL
				.path(percentEncoded: false)
			if let parent = Self.cache[parentPath]?.wrappedValue {
				withAnimation {
					parent.childrenCache = nil
				}
			}
		}
	}

	var children: [ItemModel]? {
		if let childrenCache {
			return childrenCache
		}
		let children = loadChildren()
		childrenCache = .some(children)
		return children
	}

	func loadChildren() -> [ItemModel]? {
		reloadResourceValues()
		guard exists else { return nil }
		do {
			// If we're not a directory, we can't have subdirectories
			if !isDirectory {
				return nil
			}
			return try FileManager.default
				.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isRegularFileKey])
				.lazy
				.map { ItemModel.child(at: $0, parent: self) }
				.sorted()
		} catch {
			print(error)
			return nil
		}
	}

	func reloadResourceValues() {
		guard FileManager.default.fileExists(atPath: url.path(percentEncoded: false)) else {
			exists = false
			return
		}
		exists = true
		do {
			let values = try url.resourceValues(forKeys: [
				.contentTypeKey,
				.isRegularFileKey,
				.isDirectoryKey,
			])
			contentType = values.contentType
			isRegularFile = values.isRegularFile ?? false
			isDirectory = values.isDirectory ?? false
		} catch {
			print(error)
		}
	}

	/// The display name of the item
	var displayName: String {
		get { _displayName }
		set {
			let oldValue = _displayName
			guard oldValue != newValue else { return }

			_displayName = newValue
			do {
				try FileManager.default.moveItem(at: url, to: renamed(to: newValue))
			} catch {
				print(error)
				_displayName = oldValue
			}
		}
	}

	private func renamed(to displayName: String) -> URL {
		url
			.deletingPathExtension()
			.appending(component: displayName, directoryHint: .notDirectory)
			.appendingPathExtension(url.pathExtension)
	}

	static func < (lhs: ItemModel, rhs: ItemModel) -> Bool {
		guard lhs.isDirectory == rhs.isDirectory else { return lhs.isDirectory }
		return lhs.absolutePath < rhs.absolutePath
	}
}

//TODO: get rid of this in favor of the ItemIcon view
extension ItemModel {
	var type: FileIcon.FileType? {
		let filename = url.fileName

		/// First, check if there is a valid file extension.
		if let type = FileIcon.FileType(rawValue: filename) {
			return type
		}
		/// If  there's not, verifies every extension for a valid type.
		let extensions = filename.dropFirst().components(separatedBy: ".").reversed()

		return extensions
			.compactMap { FileIcon.FileType(rawValue: $0) }
			.first
	}

	var systemImage: String {
		if children != nil {
			// item is a folder
			return folderIcon()
		} else {
			// item is a file
			return FileIcon.fileIcon(fileType: type)
		}
	}

	/// Return the icon of the file as `Image`
	var icon: Image {
		if let customImage = NSImage.symbol(named: systemImage) {
			return Image(nsImage: customImage)
		} else {
			return Image(systemName: systemImage)
		}
	}

	/// Returns a string describing a SFSymbol for folders
	///
	/// If it is the top-level folder this will return `"square.dashed.inset.filled"`.
	/// If it is a `.codeedit` folder this will return `"folder.fill.badge.gearshape"`.
	/// If it has children this will return `"folder.fill"` otherwise `"folder"`.
	private func folderIcon() -> String {
		if parent == nil {
			return "folder.fill.badge.gearshape"
		}
		if url.lastPathComponent == ".codeedit" {
			return "folder.fill.badge.gearshape"
		}
		return children == nil ? "folder" : "folder.fill"
	}
}
