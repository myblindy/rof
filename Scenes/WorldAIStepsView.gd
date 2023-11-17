extends Label

var last_selected_object

func _process(_delta: float) -> void:
	set_process(false)

	GameState.world.selected_object_changed.connect(_world_selected_object_changed)
	_world_selected_object_changed()

func _world_selected_object_changed() -> void:
	if last_selected_object:
		last_selected_object.current_ai_step_changed.disconnect(_current_ai_step_changed)

	last_selected_object = GameState.world.selected_object
	if GameState.world.selected_object:
		GameState.world.selected_object.current_ai_step_changed.connect(_current_ai_step_changed)
	_current_ai_step_changed()

func _current_ai_step_changed() -> void:
	if not GameState.world.selected_object:
		text = ""
		return
	
	var s := "AI Steps:\n"
	for step_index in GameState.world.selected_object.ai_steps.size():
		var step: BaseAIStep = GameState.world.selected_object.ai_steps[step_index]

		s += step.to_string()
		if step_index == GameState.world.selected_object.current_ai_step - 1:
			s += " (*)"
		s += "\n"

	text = s
