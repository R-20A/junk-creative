class_name BuildEditorGroupTool
extends BuildEditorVoxelPicker


class CreateGroupAction:
	var plane := Plane.PLANE_XZ
	var group := null

	
	func start_action() -> void:
		pass
	
	func process_action() -> void:
		pass

	func 


func _start_create_group() -> void:
	pass
	# 1 - create group from build master, and get a reference to it
	
	# 2 - enter a loop where you move said group with the mouse
	
	# 3A - left clicking will execute the action with the undoredo
	# 3A.5 - need to check overlaps to place (woulda be cool if voxels become red)
	
	# 3B - right clicking will cancel the action
