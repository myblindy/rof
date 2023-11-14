extends Node3D
class_name Worker

@onready var _world: World = get_owner()
@onready var _right_hand_attachment := $Armature/Skeleton3D/RightHandAttachmentParent/RightHandAttachment
@onready var _animation_tree := $AnimationTree
@onready var _animation_state_machine: AnimationNodeStateMachinePlayback = _animation_tree["parameters/playback"]

var _movement_target: Node3D
var _held_item: Node3D

signal _completed

func get_interaction_range() -> float:
	return 0.4;

func _ready() -> void:
	set_process(false)

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
		_world.add_child(_held_item)
		
	# pick up new item
	_world.remove_child(target)
	target.position = Vector3.ZERO
	target.rotation = Vector3.ZERO
	_held_item = target
	_right_hand_attachment.add_child(target)
	
	await _animation_tree.animation_finished
	_animation_state_machine.travel("idle")
	
func work_on(target: Node3D) -> void:
	await walk_to(target)
	
	if target is TreeObject and _held_item is AxeTool:
		_animation_state_machine.travel("chop")
	
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
		_animation_state_machine.travel("idle")
		_completed.emit()
		set_process(false)
