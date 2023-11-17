extends Object
class_name GameState

const log_scene := preload("res://Assets/Characters/Objects/WorldItems/log.tscn")
const plank_scene := preload("res://Assets/Characters/Objects/WorldItems/plank.tscn")

static var world: World
static var workers: Array[Worker] = []
static var available_trees: Array[TreeObject] = []
static var available_world_items: Array[BaseWorldItem] = []

static var type_helpers := preload("res://Helpers/TypeHelpers.cs").new()

const axe_tool_name := "axe"
const tree_name := "tree"
const log_name := "log"

static func find_any_item(owner: Node3D, className: String, remove: bool = false) -> BaseWorldItem:
	if className == tree_name:
		return find_tree(owner, remove)
	else:
		return find_world_item(owner, className, remove)

static func find_world_item(owner: Node3D, className: String, remove: bool = false) -> BaseWorldItem:
	var found_item: BaseWorldItem
	var found_item_distance_squared := -1.0
	
	for world_item in available_world_items:
		if type_helpers.IsInstanceOfType(world_item, className):
			var distance_squared := (world_item.position - owner.position).length_squared()
			if not found_item or found_item_distance_squared > distance_squared:
				found_item = world_item
				found_item_distance_squared = distance_squared
				
	if remove and found_item:
		available_world_items.erase(found_item)
	return found_item

static func find_tree(owner: Node3D, remove: bool = false) -> TreeObject:
	var found_tree: TreeObject
	var found_tree_distance_squared := -1.0
	
	for tree in available_trees:
		var distance_squared := (tree.position - owner.position).length_squared()
		if not found_tree or found_tree_distance_squared > distance_squared:
			found_tree = tree
			found_tree_distance_squared = distance_squared
				
	if remove and found_tree:
		available_trees.erase(found_tree)
	return found_tree

static func erase_any_item(item: BaseWorldItem):
	if type_helpers.IsInstanceOfType(item, tree_name):
		available_trees.erase(item)
	else:
		available_world_items.erase(item)
