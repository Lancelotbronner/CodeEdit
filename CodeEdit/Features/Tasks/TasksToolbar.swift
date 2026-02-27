//
//  TasksToolbar.swift
//  CodeEdit
//
//  Created by Khan Winter on 8/28/25.
//

import SwiftUI

struct TasksToolbar: ToolbarContent {
	let taskManager: TaskManager?
	let utilityArea: UtilityAreaViewModel?

	init(_ workplace: WorkspaceModel) {
		taskManager = workplace.taskManager
		utilityArea = workplace.utilityAreaModel
	}

	var body: some ToolbarContent {
		ToolbarItem(id: "StopTaskToolbarItem") {
			Button("Stop Task", systemImage: "stop.fill") {
				guard let taskManager, taskManager.currentTaskStatus == .running else { return }
				taskManager.terminateActiveTask()
			}
			.help("Stop the selected task")
			.disabled(taskManager?.currentTaskStatus != .running)
		}
		ToolbarItem(id: "StartTaskToolbarItem") {
			Button("Start Task", systemImage: "start.fill") {
				guard let taskManager, taskManager.currentTaskStatus == .running else { return }
				taskManager.executeActiveTask()
				if utilityArea?.isCollapsed ?? false {
					CommandManager.shared.executeCommand("open.drawer")
				}
				utilityArea?.selectedTab = .debugConsole
				taskManager.taskShowingOutput = taskManager.selectedTaskID
			}
			.help("Run the selected task")
			.disabled(taskManager?.currentTaskStatus != .running)
		}
	}
}
