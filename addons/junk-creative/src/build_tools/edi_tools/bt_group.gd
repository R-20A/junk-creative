class_name BuildEditorGroupTool
extends BuildEditorVoxelPicker

# 3A - left clicking will execute the action with the undoredo

# 3A.5 - need to check overlaps to place (woulda be cool if voxels become red)

# 3B - right clicking will cancel the action
class CreateGroupAction extends BuildTool.ToolAction:

	var placement_plane := Plane.PLANE_XZ
	var placement_position := Vector3.ZERO
	
	var new_group := BuildMaster.build_default_group()
	var is_group_overlapping := true # can't place

	
	func process_input(event: InputEvent) -> void:
		
		# Update placement position
		if event is InputEventMouseMotion:
			var mouse_position := tool.get_viewport().get_mouse_position()
			
			var from := camera.project_ray_origin(mouse_position)
			var to := from + camera.project_ray_normal(mouse_position) * Junk.EDITOR_RAYCAST_LENGTH
			
			var intersection_result := placement_plane.intersects_ray(from, to)
			if intersection_result:
				placement_position = intersection_result
	
		# Commit / cancel
		if event is InputEventMouseButton:
			if event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
				commit_action()
			elif event.button_index == MouseButton.MOUSE_BUTTON_RIGHT:
				cancel_action()

	
	func commit_action() -> bool:
		free.call_deferred()
		return false

	
	func cancel_action() -> void:
		BuildMaster.delete_group(new_group)
		free.call_deferred()


func _on_create_group_pressed() -> void:
	_start_action(CreateGroupAction.new())
