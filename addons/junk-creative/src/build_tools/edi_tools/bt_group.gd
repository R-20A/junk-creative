class_name BuildEditorGroupTool
extends BuildEditorVoxelPicker


func _on_create_group_pressed() -> void:
	_start_action(CreateGroupAction.new())


func _on_delete_group_pressed() -> void:
	_start_action(DeleteGroupAction.new())


# 3A - left clicking will execute the action with the undoredo
class CreateGroupAction extends BuildTool.ToolAction:

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
				placement_position = intersection_result
				new_group.position = placement_position
				BuildMaster.group_check_overlaps.call_deferred(new_group)

		# Commit / cancel
		super.process_input(event)
	
	
	func commit_action() -> void:
		var overlap_data := BuildMaster.group_check_overlaps(new_group)
		for overlap_check in overlap_data:
			if overlap_check == true:
				return
		
		cleanup_action()

	
	func cancel_action() -> void:
		BuildMaster.group_delete(new_group)
		cleanup_action()


class DeleteGroupAction extends BuildTool.ToolAction:
	var voxel_tool: BuildEditorVoxelPicker
	var result: BuildEditorVoxelPicker.VoxelQueryResult = null
	
	func start_action(tool: BuildTool) -> void:
		super.start_action(tool)
		voxel_tool = tool as BuildEditorVoxelPicker
	
	
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
