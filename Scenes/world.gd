extends Node3D
class_name World

signal selected_object_changed
var selected_object: CollisionObject3D:
	set(new_selected_object):
		selected_object = new_selected_object
		selected_object_changed.emit()

func _ready() -> void:
	GameState.world = self
	selected_object = null
	for child in get_children():
		if child is TreeObject:
			GameState.available_trees.push_back(child)
		elif child is BaseWorldItem:
			GameState.available_world_items.push_back(child)
		elif child is Worker:
			GameState.workers.push_back(child)
			
	_chopper_orders($"worker-tree")
	_chopper_orders($"worker-tree2")
	_logger_orders($"worker-log")
	
	for worker in GameState.workers:
		worker.input_event.connect(func(_camera: Camera3D, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void: 
			if event is InputEventMouseButton and event.is_pressed and event.button_index == 1:
				get_viewport().set_input_as_handled()
				selected_object = worker)
				
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed and event.button_index == 1:
		selected_object = null
	
func _chopper_orders(worker: Worker) -> void:
	worker.ai_steps = [
		PickupToolAIStep.new(worker, GameState.axe_tool_name),
		ManualRecipeAIStep.new(worker, [GameState.tree_name]),
		JumpAIStep.new(worker, 1)
	]

func _logger_orders(worker: Worker) -> void:
	worker.ai_steps = [
		PickupToolAIStep.new(worker, GameState.axe_tool_name),
		ManualRecipeAIStep.new(worker, [GameState.log_name]),
		JumpAIStep.new(worker, 1)
	]
