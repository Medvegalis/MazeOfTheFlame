extends Node3D
class_name MazeManager

# Cell data structure
var cells: Array[Array] = []
var cellPos: Array[Array] = []
var lights: Array = []
var lightSpawnPos: Array[Node] = []

# Serialized parameters
@export var curved_wall_height: float = 5.0
@export var thickness: float = 0.5  # thickness of the wall
@export var radius: float = 10.0    # radius of first ring
@export var segments_nb: int = 8
@export var rings_nb: int = 3
@export var left_wall_model: PackedScene  # Reference to the left wall scene
@export var material: Material
@export var wanted_mesh: MeshInstance3D
@export var item_spawn_number: int = 5

var item = preload("res://Scenes/LightPickUp.tscn")

var maze_node: Node3D
var maze

func _ready() -> void:
	maze_node = Node3D.new()
	maze_node.name = "Maze"
	add_child(maze_node)
	
	maze = preload("res://Scenes/MazeGeneration/Maze.gd").new() # Assuming maze.gd is your converted Maze script
	maze_node.add_child(maze)
	
	generate_rings()
	maze.generate_maze_paths(cells)
	print(item_spawn_number)
	spawn_light(item_spawn_number)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ResetMaze"):
		regenerate_maze(item_spawn_number)
		

func regenerate_maze(item_to_spawn_count: int):
	clear_maze()
	rings_nb += 5 
	generate_rings()
	maze.generate_maze_paths(cells)
	spawn_light(item_to_spawn_count)

func spawn_light(amount : int):
	lightSpawnPos = get_tree().get_nodes_in_group("LightSpawnPos")
	
	remove_random_walls(lightSpawnPos , lightSpawnPos.size()/4)
	
	var rng = RandomNumberGenerator.new()
		
	for i in range(amount):
		var index : int = rng.randf_range(i,lightSpawnPos.size())
		var cube = item.instantiate()
		if cube is Node3D:
			cube.position = lightSpawnPos[index].global_position
			lights.append(cube)
			add_child(cube)

func remove_random_walls(walls : Array, amount : int):
	var rng = RandomNumberGenerator.new()
	var index : int
	for i in range(amount):
		index = rng.randf_range(0,walls.size())
		walls[index].get_parent().queue_free()

func create_curved_wall(inner_radius: float, wall_thickness: float, angle: float, wall_rotation: float, curved_wall_segments: int) -> Node3D:
	var curved_wall_node = Node3D.new()
	curved_wall_node.name = "Curved Wall"
	
	var curved_wall = preload("res://Scenes/MazeGeneration/CircleGen.gd").new()  # Assuming curved_wall.gd is your converted CurvedWall script
	curved_wall_node.add_child(curved_wall)
	
	# Set parameters
	curved_wall.inner_radius = inner_radius
	curved_wall.outer_radius = inner_radius + wall_thickness
	curved_wall.angle = angle
	curved_wall.wall_height = curved_wall_height
	curved_wall.segments = curved_wall_segments
	
	# Generate mesh and assign material
	curved_wall.generate_mesh()
	
	if curved_wall.get_node("MeshInstance3D") and material:
		curved_wall.get_node("MeshInstance3D").material_override = material
	
	curved_wall_node.rotate_y(deg_to_rad(wall_rotation))
	#curved_wall_node.position = Vector3.ZERO
	
	return curved_wall_node

func draw_outer_ring() -> void:
	var ring_node = Node3D.new()
	ring_node.name = "OuterRing"
	maze_node.add_child(ring_node)  # Add the ring node to the maze_node
	
	var segments: Array = []
	cells.append(segments)
	
	# Curved wall parameters
	var inner_radius = radius * (rings_nb + 1)
	var teta = 360.0 / segments_nb
	var wall_rotation = 0.0
	
	for j in range(segments_nb):
		# Create parent node that holds cell data
		var current_cell = preload("res://Scenes/MazeGeneration/MazeCell.gd").new()
		current_cell.name = "(%d, %d)" % [rings_nb, j]
		current_cell.init(ring_node,ring_node.global_position.x,ring_node.global_position.z)
		#ring_node.add_child(current_cell)  # Add current cell to the ring node
		
		# Create curved wall
		var curved_wall = create_curved_wall(inner_radius, thickness, teta, wall_rotation,segments_nb)
		curved_wall.name = "Front"
		current_cell.add_child(curved_wall)  # Add curved wall to the current cell
		
		# Set wall data
		current_cell.set_walls(curved_wall, null)
		
		wall_rotation += teta
		segments.append(current_cell)


func generate_spawn_cell() -> void:
	var spawn_ring: Array = []
	
	var spawn_cell = preload("res://Scenes/MazeGeneration/MazeCell.gd").new() 
	spawn_cell.name = "Spawn cell"
	maze_node.add_child(spawn_cell)
	
	spawn_cell.set_walls(null, null)
	spawn_ring.append(spawn_cell)
	
	cells.append(spawn_ring)

func generate_rings() -> void:
	cells.clear()
	var updating_segment_nb = segments_nb
	generate_spawn_cell()
	
	cellPos = []  # Initialize the array
	
	for i in range(1, rings_nb):
		var ring_node = Node3D.new()
		ring_node.name = "Ring%d" % i
		maze_node.add_child(ring_node)
		
		var segments: Array = []
		cells.append(segments)
		
		var segmentPos: Array = []
		
		var teta = 360.0 / updating_segment_nb
		var wall_rotation = 0.0
		for j in range(updating_segment_nb):
			# Create parent node that holds cell data
			var current_cell = preload("res://Scenes/MazeGeneration/MazeCell.gd").new()
			current_cell.name = "%d, %d" % [i, j]
			current_cell.init(ring_node,ring_node.global_position.x,ring_node.global_position.z)
			#ring_node.add_child(current_cell)  # Add to scene tree
			
			# Curved wall parameters
			var inner_radius = radius * (i + 1)
			
			# Create curved wall
			var curved_wall = create_curved_wall(inner_radius, thickness, teta, wall_rotation,updating_segment_nb)
			current_cell.add_child(curved_wall)  # Add to the current cell
			
			# Create Left wall
			var orientation = Transform3D()
			orientation = orientation.rotated(Vector3(0,1,0), deg_to_rad(-90.0 + wall_rotation))
			var pos = orientation.basis * Vector3(radius * (i + 1.565), 0, 0)
			
			var left_wall = left_wall_model.instantiate()
			left_wall.position = pos
			left_wall.transform.basis = orientation.basis
			
			# Scale left wall
			left_wall.scale = Vector3(radius + thickness, curved_wall_height, thickness)
			#var light_pos =  left_wall.get_node("Node3D").global_position
			#print(light_pos)
			# Set material
			if material:
				var mesh_instance = left_wall.find_child("MeshInstance3D", true, false)
				if mesh_instance:
					mesh_instance.material_override = material
			#
			left_wall.name = "Left Wall"
			current_cell.add_child(left_wall)  # Add left wall to the current cell
			
			# Set wall data for the cell
			current_cell.set_walls(curved_wall, left_wall)
			
			wall_rotation += teta
			segments.append(current_cell)
			segmentPos.append(Vector3(pos.x , 1, pos.z))
		
		cellPos.append(segmentPos)
		# Check if we need to double the segments
		var x = floor(log(i+1)/log(2))
		updating_segment_nb = pow(2,x + 3)
	
	draw_outer_ring()

func clear_maze():
	# Iterate through the 2D array
	for row in cells:
		for node in row:
			if node:  # Ensure the node exists
				node.queue_free()  # Destroy the node
	
	for light in lights:
		if is_instance_valid(light):
			light.queue_free()
		
	cells = []
	cellPos = []
	lights = []
