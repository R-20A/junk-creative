@tool
extends EditorPlugin

const AUTOLOADS_PATH := "src/autoloads/"
const AUTOLOAD_BUILD_MASTER := "BuildMaster"


func _enable_plugin() -> void:
	var folder_path := get_plugin_folder()
	
	# Add autoloads here.
	add_autoload_singleton(AUTOLOAD_BUILD_MASTER, folder_path.path_join(AUTOLOADS_PATH).path_join("al_build_master.gd"))


func _disable_plugin() -> void:
	# Remove autoloads here.
	remove_autoload_singleton(AUTOLOAD_BUILD_MASTER)



func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass


func get_plugin_folder() -> String:
	return (self.get_script() as Resource).resource_path.get_base_dir()
