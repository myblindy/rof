extends Label

func _process(_delta: float) -> void:
	set_process(false)
	
	GameState.world.selected_object_changed.connect(_world_selected_object_changed)
	_world_selected_object_changed()

func _world_selected_object_changed() -> void:
	if GameState.world.selected_object:
		text = "Selected: " + GameState.world.selected_object.name
	else:
		text = "Selected: (none)"
