extends CollisionObject3D
class_name Worker

@onready var _right_hand_attachment := $Armature/Skeleton3D/RightHandAttachmentParent/RightHandAttachment
@onready var _animation_tree := $AnimationTree
@onready var _animation_state_machine: AnimationNodeStateMachinePlayback = _animation_tree["parameters/playback"]

var _movement_target: Node3D
var held_item: Node3D

var ai_steps: Array[BaseAIStep] = []
signal current_ai_step_changed
var current_ai_step: int:
	set(new_current_ai_step):
		current_ai_step = new_current_ai_step
		current_ai_step_changed.emit()

signal _completed

enum AnimationType { Idle, Walk, PickUp, Chop }

func get_interaction_range() -> float:
	return 0.2;

func _ready() -> void:
	$Nameplate.text = name
	run_ai()
	set_process(false)

func set_animation(animation_type: AnimationType) -> void:
	var animation_name: String
	match animation_type:
		AnimationType.Idle:
			animation_name = "idle"
		AnimationType.Walk:
			animation_name = "walk"
		AnimationType.PickUp:
			animation_name = "pick-up"
		AnimationType.Chop:
			animation_name = "chop"
	_animation_state_machine.travel(animation_name)
 
func walk_to(target: Node3D) -> void:
	set_animation(AnimationType.Walk)
	_movement_target = target
	look_at(_movement_target.position)
	set_process(true)
	await _completed
	
func pick_up(target: Node3D) -> void:
	await walk_to(target)
	
	# TODO: pickup time
	set_animation(AnimationType.PickUp)
	await get_tree().create_timer(2.5).timeout
	
	# drop held item
	if held_item:
		_right_hand_attachment.remove_child(held_item)
		held_item.position = position
		GameState.world.add_child(held_item)
		
	# pick up new item
	GameState.world.remove_child(target)
	target.position = Vector3.ZERO
	target.rotation = Vector3.ZERO
	held_item = target
	_right_hand_attachment.add_child(target)
	
	await _animation_tree.animation_finished
	set_animation(AnimationType.Idle)

func run_ai():
	while true:
		if current_ai_step < ai_steps.size():
			var ai_step := ai_steps[current_ai_step]
			current_ai_step += 1
			await ai_step.run()
		else:
			await get_tree().process_frame
	
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
		set_animation(AnimationType.Idle)
		_completed.emit()
		set_process(false)
