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
		if child is WorldItemBase:
			GameState.available_world_items.push_back(child)
		elif child is Worker:
			GameState.workers.push_back(child)
		elif child is TreeObject:
			GameState.available_trees.push_back(child)
			
	_chopper_orders($"worker-tree")
	_chopper_orders($"worker-tree2")
	_logger_orders($"worker-log")
	
	for worker in GameState.workers:
		worker.input_event.connect(func(camera: Camera3D, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int) -> void: 
			if event is InputEventMouseButton and event.is_pressed and event.button_index == 1:
				get_viewport().set_input_as_handled()
				selected_object = worker)
				
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed and event.button_index == 1:
		selected_object = null
	
func _chopper_orders(worker: Worker) -> void:
	# get tool
	while true:
		var axe := GameState.find_world_item(worker, "axe", true)
		if axe:
			await worker.pick_up(axe)
			break
		await get_tree().process_frame
	
	# chop tree
	while true:	
		var tree := GameState.find_tree(worker, true)
		if tree:
			await worker.work_on(tree)
		await get_tree().process_frame

func _logger_orders(worker: Worker) -> void:
	# get tool
	while true:
		var axe := GameState.find_world_item(worker, "axe", true)
		if axe:
			await worker.pick_up(axe)
			break
		await get_tree().process_frame
		
	# refine a log
	while true:
		var log := GameState.find_world_item(worker, "log", true)
		if log:
			await worker.work_on(log)
		await get_tree().process_frame
