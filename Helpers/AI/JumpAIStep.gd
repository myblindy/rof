extends BaseAIStep
class_name JumpAIStep

var _worker: Worker
var _new_ai_step_index: int

func _init(worker: Worker, new_ai_step_index: int):
	_worker = worker
	_new_ai_step_index = new_ai_step_index
	
func _to_string() -> String:
	return "Jump to step " + str(_new_ai_step_index)

func run():
	_worker.current_ai_step = _new_ai_step_index
