## Can pick up on voxels using the mouse.
class_name BuildEditorVoxelPicker
extends BuildEditorTool


var pick_data: VoxelQueryResult

var _voxel_ray: RayCast3D


func initialize_editor_tool(editor: JunkCreativeEditor) -> void:
	super.initialize_editor_tool(editor)
	
	_voxel_ray = RayCast3D.new()
	camera.add_child(_voxel_ray)
	
	_voxel_ray.collision_mask = 0
	_voxel_ray.set_collision_mask_value(Junk.PHY_LAYER_VOXEL, true)
	_voxel_ray.collide_with_bodies = true
	
	_voxel_ray.target_position = Vector3.FORWARD * Junk.EDITOR_RAYCAST_LENGTH
	_voxel_ray.enabled = false
	
	pick_data = VoxelQueryResult.new()


func cleanup_tool() -> void:
	super.cleanup_tool()
	
	camera.remove_child(_voxel_ray)
	_voxel_ray.queue_free()


func process_input(event: InputEvent) -> void:
	super.process_input(event)


func process_tool(delta: float) -> void:
	super.process_tool(delta)


## Event must be of type "InputEventMouseMotion"!!! [br]
## Returns [VoxelQueryResult] if hit, else null.
func query_build_voxels() -> VoxelQueryResult:
	# reset query data
	pick_data.voxel = null
	pick_data.normal = Vector3.ZERO
	
	_voxel_ray.target_position = camera.project_local_ray_normal( get_viewport().get_mouse_position() ).normalized()
	_voxel_ray.target_position *= Junk.EDITOR_RAYCAST_LENGTH
	_voxel_ray.force_raycast_update()
	
	print(_voxel_ray.is_colliding())
	
	if _voxel_ray.is_colliding():
		
		var voxel_body := _voxel_ray.get_collider() as StaticBody3D
		var shape_id := _voxel_ray.get_collider_shape()
		var owner_id := voxel_body.shape_find_owner(shape_id)
		
		# This should work.
		pick_data.voxel = voxel_body.shape_owner_get_owner(owner_id) as VoxelInstance
		pick_data.normal = _voxel_ray.get_collision_normal()
		
		pick_data.voxel.debug_color = Color.ORANGE

		return pick_data
		
	else:
		return null


class VoxelQueryResult:
	var voxel: VoxelInstance = null
	var normal: Vector3 = Vector3.MODEL_FRONT
