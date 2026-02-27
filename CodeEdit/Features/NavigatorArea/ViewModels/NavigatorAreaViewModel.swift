//
//  NavigatorAreaViewModel.swift
//  CodeEdit
//
//  Created by Abe Malla on 7/23/23.
//

import Foundation

@Observable
final class NavigatorAreaViewModel {
    var selectedTab: NavigatorTab? = .project
    /// The tab bar items in the Navigator
    var tabItems: [NavigatorTab] = []

    func setNavigatorTab(tab newTab: NavigatorTab) {
        selectedTab = newTab
    }
}
