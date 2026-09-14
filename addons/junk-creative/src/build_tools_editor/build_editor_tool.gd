## Same as [BuildTool], but references the editor instead for undo/redo.
class_name BuildEditorTool
extends Control

var editor: JunkCreativeEditor
var camera: Camera3D


func initialize_editor_tool(editor: JunkCreativeEditor) -> void:
	self.editor = editor
	self.camera = editor.camera


func cleanup_tool() -> void:
	pass


func process_input(event: InputEvent) -> void:
	pass


func process_tool(delta: float) -> void:
	pass
