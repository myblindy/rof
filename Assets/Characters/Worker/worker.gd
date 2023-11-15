extends CollisionObject3D
class_name Worker

@onready var _right_hand_attachment := $Armature/Skeleton3D/RightHandAttachmentParent/RightHandAttachment
@onready var _animation_tree := $AnimationTree
@onready var _animation_state_machine: AnimationNodeStateMachinePlayback = _animation_tree["parameters/playback"]

var _movement_target: Node3D
var _held_item: Node3D

signal _completed

func get_interaction_range() -> float:
	return 0.2;

func _ready() -> void:
	set_process(false)
	
func _set_idle() -> void:
	_animation_state_machine.travel("idle")

func walk_to(target: Node3D) -> void:
	_animation_state_machine.travel("walk")
	_movement_target = target
	look_at(_movement_target.position)
	set_process(true)
	await _completed
	
func pick_up(target: Node3D) -> void:
	await walk_to(target)
	
	# TODO: pickup time
	_animation_state_machine.travel("pick-up")
	await get_tree().create_timer(2.5).timeout
	
	# drop held item
	if _held_item:
		_right_hand_attachment.remove_child(_held_item)
		_held_item.position = position
		GameState.world.add_child(_held_item)
		
	# pick up new item
	GameState.world.remove_child(target)
	target.position = Vector3.ZERO
	target.rotation = Vector3.ZERO
	_held_item = target
	_right_hand_attachment.add_child(target)
	
	await _animation_tree.animation_finished
	_set_idle()
	
func work_on(target: Node3D) -> void:
	if target is TreeObject and _held_item is AxeTool:
		await walk_to(target)
	
		_animation_state_machine.travel("chop")
		await get_tree().create_timer(target.get_interaction_duration_sec()).timeout
		
		# destroy tree and add log in its place
		target.queue_free()
		
		var log := GameState.log_scene.instantiate()
		log.position = target.position
		log.rotation = Vector3(0, randf_range(0, PI * 2), 0)
		GameState.available_world_items.push_back(log)
		GameState.world.add_child(log)
		
		_set_idle()
		
	elif target is LogObject and _held_item is AxeTool:
		await walk_to(target)
		
		_animation_state_machine.travel("chop")
		await get_tree().create_timer(target.get_interaction_duration_sec()).timeout
		
		# destroy log and add plank in its place
		target.queue_free()
		
		for i in 3:
			var plank := GameState.plank_scene.instantiate()
			plank.position = target.position + Vector3(0, i * 0.1, 0)
			plank.rotation = Vector3(0, randf_range(0, PI * 2), 0)
			GameState.available_world_items.push_back(plank)
			GameState.world.add_child(plank)
			
		_set_idle()
		
	
func _process(delta: float) -> void:
	var movement_direction := _movement_target.position - position
	var interaction_range: float = get_interaction_range() + _movement_target.get_interaction_range()
	var distance_sq := movement_direction.length_squared() - interaction_range * interaction_range
	
	if distance_sq > interaction_range * interaction_range:
		# TODO: speed value
		var speed := delta * 1
		if speed * speed > distance_sq:
			speed = movement_direction.length() - interaction_range
		movement_direction = movement_direction.normalized()
		
		position = position + movement_direction * speed
	else:
		_set_idle()
		_completed.emit()
		set_process(false)
