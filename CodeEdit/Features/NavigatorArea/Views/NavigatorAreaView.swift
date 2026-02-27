//
//  NavigatorAreaView.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 17.03.22.
//

import SwiftUI

struct NavigatorAreaView: View {
    let workspace: WorkspaceModel
    @ObservedObject private var extensionManager = ExtensionManager.shared
    @Bindable var viewModel: NavigatorAreaViewModel

    @AppSettings(\.general.navigatorTabBarPosition)
    var sidebarPosition: SettingsData.SidebarTabBarPosition

    var body: some View {
        WorkspacePanelView(
            viewModel: viewModel,
            selectedTab: $viewModel.selectedTab,
            tabItems: $viewModel.tabItems,
            sidebarPosition: sidebarPosition
		)
		.onAppear {
			viewModel.tabItems = [.project, .sourceControl, .search] +
			extensionManager
				.extensions
				.map { ext in
					ext.availableFeatures.compactMap {
						if case .sidebarItem(let data) = $0, data.kind == .navigator {
							return NavigatorTab.uiExtension(endpoint: ext.endpoint, data: data)
						}
						return nil
					}
				}
				.joined()
		}
        .environment(workspace)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("navigator")
    }
}
