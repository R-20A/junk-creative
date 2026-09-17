## Defines a block, and the paths to its assets. [br]
## Separated from the instance to not load the entire game thing just when browsing UI.
class_name BlockDefinition
extends Resource

@export var voxels: BlockVoxels
@export var instance_script: Script # Wish I could specify the script to be of a specific class...
@export var mesh_render: Mesh
@export var mesh_physics: Mesh


func make_instance() -> BlockInstance:
	var instance := BlockInstance.new()
	instance.set_script(instance_script)
	instance.res = self
	
	return instance


## For thumbnails or placing blocks
func make_preview_scene() -> Node3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = mesh_render
	
	return mesh_instance
