extends Node3D
class_name Maze_cell

# Node references
var front_node: Node3D
var left_node: Node3D

var front_static_body: CollisionShape2D
var left_static_body: CollisionShape2D

# Private variables
var _x: float
var _z: float

# Structure equivalent using a dictionary
var _data: Dictionary = {
	"front": false,  # front wall
	"left": false    # left wall
}

# Called when the node enters the scene tree
func _ready():
	pass

# Initialize the cell
func init(parent: Node, x: float = 0.0, z: float = 0.0) -> void:
	# In Godot, we use add_child instead of setting parent directly
	if parent != get_parent():
		if get_parent():
			get_parent().remove_child(self)
		parent.add_child(self)
	
	# Set position
	position = Vector3(x, -0.1, z)

# Set wall node references
func set_walls(front_wall: Node3D, left_wall: Node3D) -> void:
	if(front_wall == null or left_wall == null):
		return
	front_node = front_wall
	left_node = left_wall
	
	front_static_body = find_static_body_in_children(front_wall)
		
	# Find and assign the StaticBody3D in the left wall
	left_static_body = find_static_body_in_children(left_wall)
	
func find_static_body_in_children(parent: Node) -> CollisionShape2D:
	if(parent.get_child_count() == 0):
		return
		
	for child in parent.get_children():
		if child is CollisionShape2D:
			return child
		elif child.get_child_count() > 0:
			var found = find_static_body_in_children(child)
			if found:
				return found
	return null

# Set front wall visibility
func set_front(value: bool) -> void:
	if front_node:
		_data["front"] = value
		front_node.queue_free()
		if(front_static_body):
			front_static_body.disable = value
	else:
		print("Exception: null front wall node")

# Set left wall visibility
func set_left(value: bool) -> void:
	if left_node:
		_data["left"] = value
		left_node.queue_free()
		if(left_static_body):
			left_static_body.coll = value
	else:
		print("Exception: null left wall node")
