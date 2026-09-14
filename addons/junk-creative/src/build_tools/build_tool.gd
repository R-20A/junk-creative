## A tool, for building, that works relative to a camera and interacts with the [BuildMaster]
## A tool is essentially a huge UI that takes the entire screen, or what's available.
class_name BuildTool
extends Control


class ToolAction extends Object:
	var can_commit := false
	
	func start_action() -> void:
		pass
	
	
	func process_action() -> void:
		pass

	
	func commit_action() -> bool:
		return false

	
	func cancel_action() -> void:
		free()


var camera: Camera3D


func initialize_tool(camera: Camera3D) -> void:
	pass


func cleanup_tool() -> void:
	pass


func process_tool(delta: float) -> void:
	pass
