extends Camera3D

func _process(delta: float) -> void:
	var forward := global_transform.basis.z.normalized() * 8 * delta
	
	if Input.is_action_pressed("camera_left"):
		transform.origin += forward.cross(Vector3.UP)
	if Input.is_action_pressed("camera_right"):
		transform.origin -= forward.cross(Vector3.UP)
	if Input.is_action_pressed("camera_up"):
		transform.origin -= forward.cross(Vector3.UP).rotated(Vector3.UP, PI / 2)
	if Input.is_action_pressed("camera_down"):
		transform.origin += forward.cross(Vector3.UP).rotated(Vector3.UP, PI / 2)
