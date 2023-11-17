extends BaseAIStep
class_name ManualRecipeAIStep

var _worker: Worker
var _input_names: Array[String]

func _init(worker: Worker, input_names: Array[String]):
	_worker = worker
	_input_names = input_names

func _to_string() -> String:
	return "Recipe from [" + str(_input_names) + "]" 

func run():
	while true:
		var inputs: Array[Node3D] = []
		for input_name in _input_names:
			var input := GameState.find_any_item(_worker, input_name)
			if not input:
				break
			inputs.append(input)
		
		# did we find everything?
		if inputs.size() == _input_names.size():

			# erase the items from being available anymore
			for input in inputs:
				GameState.erase_any_item(input)

			await RecipeController.work(_worker, inputs)
			return  # done
		
		await _worker.get_tree().process_frame
