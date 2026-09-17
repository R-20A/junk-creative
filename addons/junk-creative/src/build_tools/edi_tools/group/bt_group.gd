extends BuildEditorVoxelPicker


func _on_create_group_pressed() -> void:
	_start_action(CreateGroupAction.new())


func _on_transform_group_pressed() -> void:
	_start_action(TransformGroupAction.new())


func _on_delete_group_pressed() -> void:
	_start_action(DeleteGroupAction.new())


# 3A - left clicking will execute the action with the undoredo
class CreateGroupAction extends BuildTool.Action:
	var placement_plane := Plane.PLANE_XZ
	var placement_position := Vector3.ZERO
	
	var new_group := BuildMaster.build_default_group()
	var is_group_overlapping := true # can't place

	
	func start_action(tool: BuildTool) -> void:
		super.start_action(tool)
	
	
	func process_input(event: InputEvent) -> void:
		
		# Update placement position
		if event is InputEventMouseMotion:
			var mouse_position := tool.get_viewport().get_mouse_position()
			
			var from := camera.project_ray_origin(mouse_position)
			var to := from + camera.project_ray_normal(mouse_position) * Junk.EDITOR_RAYCAST_LENGTH
			
			var intersection_result := placement_plane.intersects_segment(from, to)
			if intersection_result:
				placement_position = intersection_result.snappedf(0.5)
				new_group.position = placement_position
				BuildMaster.group_check_overlaps.call_deferred(new_group)

		# Commit / cancel
		super.process_input(event)
	
	
	func commit_action() -> void:
		if BuildMaster.group_is_overlapping(new_group):
			return
		
		cleanup_action()

	
	func cancel_action() -> void:
		BuildMaster.group_delete(new_group)
		cleanup_action()


class TransformGroupAction extends BuildEditorVoxelPicker.Action:
	# TODO: gizmo supports message for precise values, 
	# I should add a label similar to how it's done in the Gizmo3D demo
	var gizmo := GroupTransformGizmo3D.new()
	
	func start_action(tool: BuildTool) -> void:
		super.start_action(tool)
		
		tool.add_child(gizmo)
	
	
	func process_input(event: InputEvent) -> void:
		if event is InputEventMouseButton:
			
			if is_main_event(event):
				gizmo.group = null
				
				result = voxel_tool.query_build_voxels()
				if result and result.voxel:
					
					# Select group owner
					gizmo.group = result.voxel.block_instance.owner
			
			
			#elif is_cancel_event(event):
				#gizmo.clear_selection()


	func cleanup_action():
		tool.remove_child(gizmo)
		gizmo.queue_free()
		super.cleanup_action()
	


class DeleteGroupAction extends BuildEditorVoxelPicker.Action:
	func process_input(event: InputEvent) -> void:
		if event is InputEventMouseMotion:
			result = voxel_tool.query_build_voxels()
		
		# Commit / cancel
		super.process_input(event)


	func commit_action() -> void:
		result = voxel_tool.query_build_voxels()
		if result and result.voxel:
			BuildMaster.group_delete(result.voxel.block_instance.owner)
			cleanup_action()
