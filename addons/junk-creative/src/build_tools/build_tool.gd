## A tool, for building, that works relative to a camera and interacts with the [BuildMaster]
## A to	ol is essentially a huge UI that takes the entire screen, or what's available.
class_name BuildTool
extends Control

var camera: Camera3D


func initialize_tool(camera: Camera3D) -> void:
	pass


func cleanup_tool() -> void:
	pass


func process_tool(delta: float) -> void:
	pass
