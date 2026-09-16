@tool
class_name GizmoLoader
extends EditorPlugin
## <summary>
## Plugin that add/removes the <see cref="Gizmo3D"/> node.
## </summary>

func _enter_tree() -> void:
	add_custom_type("Gizmo3D", "Node3D", ResourceLoader.load( get_plugin_folder().path_join("gizmo_loader.gd") ), null)

func _exit_tree() -> void:
	remove_custom_type("Gizmo3D")


func get_plugin_folder() -> String:
	return (self.get_script() as Resource).resource_path.get_base_dir()
