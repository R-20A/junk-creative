class_name JunkCreativeEditor
extends Node3D

#region Tools
const PACKED_TOOL_SELECT := preload("uid://dp6c42hsghmwb")
const PACKED_TOOL_BUILD := preload("uid://drvdfmwo43os3")
const PACKED_TOOL_PAINT_VERTEX := preload("uid://gox5pwry6a8c")
#endregion


@export_group("Internal References")

@export var world: Node3D
@export var camera: Camera3D

@export var tool_container: Control


var current_tool: BuildTool


#region Buttons
func exit_editor() -> void:
	pass


func load_creation() -> void:
	pass


func save_creation() -> void:
	pass


func tool_select() -> void:
	_switch_tool(PACKED_TOOL_SELECT)


func tool_build() -> void:
	_switch_tool(PACKED_TOOL_BUILD)


func tool_paint() -> void:
	_switch_tool(PACKED_TOOL_PAINT_VERTEX)
#endregion



func _switch_tool(packed_tool_scene: PackedScene) -> void:
	if current_tool:
		tool_container.remove_child(current_tool)
		current_tool.cleanup_tool()
		current_tool.queue_free()

	current_tool = packed_tool_scene.instantiate()
	tool_container.add_child(current_tool)
	
	current_tool.initialize_tool(camera)
