## A tool, for building, that works relative to a camera and interacts with the [BuildMaster]
## A tool is essentially a huge UI that takes the entire screen, or what's available.
class_name BuildTool
extends Control


## Remember to delete itself
class ToolAction extends Object:
	var tool: BuildTool
	var can_commit := false
	
	var camera: Camera3D = null
	
	
	func start_action(tool: BuildTool) -> void:
		self.tool = tool
		self.camera = tool.camera
	
	
	func process_input(event: InputEvent) -> void:
		pass
	
	
	func process(delta: float) -> void:
		pass
	
	
	func commit_action() -> bool:
		free.call_deferred()
		return false

	
	func cancel_action() -> void:
		free()


var camera: Camera3D
var current_action: ToolAction


func initialize_tool(camera: Camera3D) -> void:
	pass


func cleanup_tool() -> void:
	if current_action:
		current_action.cancel_action()


func process_input(event: InputEvent) -> void:
	if current_action:
		current_action.process_input(event)


func process_tool(delta: float) -> void:
	if current_action:
		current_action.process(delta)


func _start_action(action: ToolAction) -> void:
	if current_action:
		current_action.cancel_action.call_deferred()
		current_action.free.call_deferred()

	set_deferred("current_action", action)
	action.start_action.call_deferred(self)
