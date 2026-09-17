## https://github.com/chrisizeful/Gizmo3D/blob/main/demo/DemoScript/custom_gizmo.gd
class_name GroupTransformGizmo3D
extends Gizmo3D

var group: BuildGroup:
	set(value):
		clear_selection()
		if value:
			group = value
			select(group.phys_body)


func _ready() -> void:
	super._ready()
	transform_begin.connect(func(mode): print("Begin ", TransformMode.keys()[mode]))
	transform_changed.connect(func(mode, value): print("Change ", TransformMode.keys()[mode], ": ", value))
	transform_end.connect(func(mode): print("End ", TransformMode.keys()[mode]))


## Example of overriding translating to always snap to 2 units.
func _edit_translate(translation : Vector3) -> Vector3:
	var new_translation := translation.snappedf(Junk.VOXEL_SIZE)
	
	# check if moving the group would make it overlap with any other group
	var overlap_test_transform := group.transform
	overlap_test_transform.origin += new_translation
	
	if BuildMaster.group_is_overlapping(group, overlap_test_transform):
		return Vector3.ZERO
	return new_translation


## Example of overriding scaling to maintain ratio on all axes.
func _edit_scale(scale : Vector3) -> Vector3:
	return Vector3.ZERO


## Example of overriding rotating to not allow the user to rotate more than
## Pi / 2 (90) degrees on any axis at one time.
func _edit_rotate(rotation : Vector3) -> Vector3:
	var new_rotation := rotation.snappedf(PI / 4).normalized()
	
	# check if rotating the group would make it overlap with any other group
	var overlap_test_transform := group.transform
	overlap_test_transform.basis *= Basis.from_euler(new_rotation)
	
	if BuildMaster.group_is_overlapping(group, overlap_test_transform):
		return Vector3.ZERO
	return new_rotation
