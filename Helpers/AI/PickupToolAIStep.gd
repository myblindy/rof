extends BaseAIStep
class_name PickupToolAIStep

var _tool_name: String
var _worker: Worker

func _init(worker: Worker, tool_name: String) -> void:
	_worker = worker    
	_tool_name = tool_name

func _to_string() -> String:
	return "Pick up tool: " + _tool_name

func run():
	while true:
		var tool_instance := GameState.find_world_item(_worker, _tool_name, true)
		if tool_instance:
			await _worker.pick_up(tool_instance)
			return
		await _worker.get_tree().process_frame
