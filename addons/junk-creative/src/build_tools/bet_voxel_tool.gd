## Can pick up on voxels using the mouse.
class_name BuildEditorVoxelPicker
extends BuildEditorTool

class VoxelPickData:
	var is_colliding := false
	var voxel_shape: CollisionShape3D = null
	var normal: Vector3 = Vector3.MODEL_FRONT


var pick_data: VoxelPickData

var _voxel_ray: RayCast3D


func initialize_editor_tool(editor: JunkCreativeEditor) -> void:
	super.initialize_editor_tool(editor)
	
	_voxel_ray = RayCast3D.new()
	_voxel_ray.collision_mask = 0
	_voxel_ray.set_collision_mask_value(Junk.PHY_LAYER_VOXEL, true)
	_voxel_ray.target_position = Vector3.FORWARD * Junk.EDITOR_RAYCAST_LENGTH
	
	camera.add_child(_voxel_ray)
	
	pick_data = VoxelPickData.new()


func cleanup_tool() -> void:
	camera.remove_child(_voxel_ray)
	_voxel_ray.queue_free()
	pick_data.free()


func process_input(event: InputEvent) -> void:
	# Mouse picking
	if event is InputEventMouseMotion:
		_update_voxel_pick(event)


func process_tool(delta: float) -> void:
	pass


func _update_voxel_pick(mouse_event: InputEventMouseMotion) -> void:
	# reset stuff
	pick_data.is_colliding = false
	
	_voxel_ray.position = camera.project_ray_origin( get_viewport().get_mouse_position() )
	
	_voxel_ray.force_raycast_update()
	if _voxel_ray.is_colliding():
		pick_data.is_colliding = true
		
		var voxel_body := _voxel_ray.get_collider() as StaticBody3D
		var shape_id := _voxel_ray.get_collider_shape()
		var owner_id := voxel_body.shape_find_owner(shape_id)
		
		# This should work.
		pick_data.voxel_shape = voxel_body.shape_owner_get_owner(owner_id)
		pick_data.normal = _voxel_ray.get_collision_normal()
