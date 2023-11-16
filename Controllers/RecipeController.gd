extends Object
class_name RecipeController

static func work(worker: Worker, tool: BaseTool, inputs: Array[Node3D]) -> Array[WorldItemBase]:
	
	# cut tree
	if tool is AxeTool and inputs.size() == 1 and inputs[0] is TreeObject:
		var tree := inputs[0] as TreeObject
		await worker.walk_to(tree)
		
		worker.set_animation(Worker.AnimationType.Chop)
		await worker.get_tree().create_timer(tree.get_interaction_duration_sec()).timeout
		
		# destroy tree and add log_instance in its place
		tree.queue_free()
		
		var log_instance := GameState.log_scene.instantiate()
		log_instance.position = tree.position
		log_instance.rotation = Vector3(0, randf_range(0, PI * 2), 0)
		GameState.available_world_items.push_back(log_instance)
		GameState.world.add_child(log_instance)
		
		worker.set_animation(Worker.AnimationType.Idle)

		return [log_instance]
	
	# refine logs into planks
	if tool is AxeTool and inputs.size() == 1 and inputs[0] is LogObject:
		var log_object := inputs[0] as LogObject
		await worker.walk_to(log_object)
		
		worker.set_animation(Worker.AnimationType.Chop)
		await worker.get_tree().create_timer(log_object.get_interaction_duration_sec()).timeout
		
		# destroy log_object and add planks in its place
		log_object.queue_free()
		
		var result: Array[WorldItemBase] = []
		for i in 3:
			var plank := GameState.plank_scene.instantiate()
			plank.position = log_object.position + Vector3(0, i * 0.1, 0)
			plank.rotation = Vector3(0, randf_range(0, PI * 2), 0)
			GameState.available_world_items.push_back(plank)
			GameState.world.add_child(plank)
			result.push_back(plank)
		
		worker.set_animation(Worker.AnimationType.Idle)

		return result

	return []
