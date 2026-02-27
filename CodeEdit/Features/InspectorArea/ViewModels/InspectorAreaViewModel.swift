//
//  InspectorAreaViewModel.swift
//  CodeEdit
//
//  Created by Abe Malla on 9/23/23.
//

import Foundation

@Observable
final class InspectorAreaViewModel {
    var selectedTab: InspectorTab? = .file
    /// The tab bar items in the Inspector
    var tabItems: [InspectorTab] = []

    func setInspectorTab(tab newTab: InspectorTab) {
        selectedTab = newTab
    }
}
