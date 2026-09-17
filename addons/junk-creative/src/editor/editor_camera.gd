## https://github.com/chrisizeful/Gizmo3D/blob/main/demo/DemoScript/camera_script.gd
class_name EditorCamera
extends Camera3D


const MOVE_SPEED := 20.0
const MOUSE_SENS := .25


func _process(delta: float) -> void:
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var move := (basis * Vector3(input.x, 0, input.y)).normalized()
	position += move * MOVE_SPEED * delta


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	elif event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var pitch = clamp(event.relative.y * MOUSE_SENS, -90, 90)
		rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENS))
		rotate_object_local(Vector3(1.0, 0.0, 0.0), deg_to_rad(-pitch))
