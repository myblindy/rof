extends Node3D
class_name World

func _ready() -> void:
	_orders_1()
	_orders_2()
	
func _orders_1() -> void:
	await $worker.pick_up($axe)
	await $worker.work_on($tree)
	
func _orders_2() -> void:
	await $worker2.pick_up($axe2)
	await $worker2.work_on($tree2)
