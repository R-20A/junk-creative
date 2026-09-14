## Same as [BuildTool], but has an extra initializer to work with the editor instead for undo/redo.
class_name BuildEditorTool
extends BuildTool


var editor: JunkCreativeEditor
var undo_redo: UndoRedo


func initialize_editor_tool(editor: JunkCreativeEditor) -> void:
	self.editor = editor
	self.camera = editor.camera
	self.undo_redo = editor.undo_redo
