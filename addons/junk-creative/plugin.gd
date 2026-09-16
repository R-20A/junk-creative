@tool
extends EditorPlugin

const AUTOLOADS_PATH := "src/autoloads/"
const AUTOLOAD_BUILD_MASTER := "BuildMaster"

const SUB_PLUGIN_PATH := "addons/"
const PLUGIN_GIZMO3D := "Gizmo3DScript"

var folder_path: String


func _enable_plugin() -> void:
	# Add autoloads here.
	
	EditorInterface.set_plugin_enabled(SUB_PLUGIN_PATH+PLUGIN_GIZMO3D, true)
	
	folder_path = get_plugin_folder()
	add_autoload_singleton(AUTOLOAD_BUILD_MASTER, folder_path.path_join(AUTOLOADS_PATH).path_join("al_build_master.gd"))


func _disable_plugin() -> void:
	# Remove autoloads here.
	remove_autoload_singleton(AUTOLOAD_BUILD_MASTER)
	
	EditorInterface.set_plugin_enabled(SUB_PLUGIN_PATH+PLUGIN_GIZMO3D, false)


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass


#region Plugin Utilities
func get_plugin_folder() -> String:
	return (self.get_script() as Resource).resource_path.get_base_dir()

"""
func _load_sub_plugins(folder_path: String) -> void:
	plugin_names = []
	
	var dir = DirAccess.open(folder_path)
	if not dir:
		return
	
	dir.list_dir_begin()
	var dir_name = dir.get_next()
	
	while dir_name != "":
		# Ensure we are looking at a directory, skipping '.' and '..'
		if dir.current_is_dir() and not dir_name.begins_with("."):
			
			var plugin_folder := folder_path.path_join(dir_name)
			var config_path = plugin_folder.path_join("plugin.cfg")
			
			# Check if it contains a valid Godot plugin config file
			if FileAccess.file_exists(config_path):
				
				plugin_names.push_back(plugin_folder)
				
				# Enable the plugin inside the current editor session
				print("Enabling sub-plugin: ", plugin_folder)
				
				# Note: 'dir_name' acts as the plugin name/folder identifier
				EditorInterface.set_plugin_enabled(plugin_folder, true)
				
				
		dir_name = dir.get_next()
		
	dir.list_dir_end()


func _unload_sub_plugins() -> void:
	for sub_plugin_name in plugin_names:
		EditorInterface.set_plugin_enabled(sub_plugin_name, false)
	
	plugin_names.clear()
"""
#endregion
