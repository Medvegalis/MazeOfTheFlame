extends Node3D

# Parameters to control animation
@export var delay: float = 0.5

# Reference of game manager and cell data structure
var game_manager: Node
var cells: Array[Array] = []
var cellsHeatMap: Array[Array] = []

# Additional variables for maze generation
var rings_nb: int
var visited: Array[Array] = []
var rng = RandomNumberGenerator.new()

var exit: int
var active_coroutines: int = 0
var is_generating: bool = false

var max_distance: float = 0.0  # To store the maximum distance for color normalization
var heat_map_cubes: Array[Node3D] = [] 
var distances = {}

func _ready():
	#game_manager = get_node("/root/GameManager")
	pass

func generate_maze_paths(cells_ref: Array) -> void:
	cells = cells_ref
	cellsHeatMap = cells_ref
	rings_nb = cells.size()

	# Initialize visited array
	visited.clear()
	for i in range(cells.size()):
		visited.append([])
		for _j in range(cells[i].size()):
			visited[i].append(false)
	
	# Randomly choose an exit in the outermost ring
	var exit_segment = rng.randi() % cells[-1].size()
	exit = exit_segment
	print("EXIT : %d, %d" % [rings_nb - 1, exit_segment])
	color_cell(Vector2i(rings_nb - 1, exit_segment), Color.RED)
	
	# Start the maze generation from the exit
	is_generating = true
	visit_cell(rings_nb - 1, exit_segment)
	coroutine_complete()

func visit_cell(ring: int, segment: int) -> void:
	visited[ring][segment] = true
	
	# Get a list of all neighbors, shuffle it to ensure random order
	var neighbors = get_unvisited_neighbors(ring, segment)
	shuffle_array(neighbors)
		
	for neighbor in neighbors:
		color_cell(neighbor, Color.YELLOW)
	
	for neighbor in neighbors:
		var neighbor_ring = neighbor.x
		var neighbor_segment = neighbor.y
		
		color_cell(neighbor, Color.WHITE)
		
		# If the neighbor has not been visited
		if not visited[neighbor_ring][neighbor_segment]:
			# Remove the wall between the current cell and the chosen cell
			remove_wall_between(ring, segment, neighbor_ring, neighbor_segment)
			
			# Recursively visit the chosen cell
			visit_cell(neighbor_ring, neighbor_segment)
		
	

func coroutine_complete() -> void:
	print("All instances of the recursive coroutine have completed.")
	is_generating = false

func color_cell(cell: Vector2i, color: Color) -> void:
	pass
	#cells[cell.x][cell.y].set_front_color(color)
	#cells[cell.x][cell.y].set_left_color(color)

func get_unvisited_neighbors(ring: int, segment: int) -> Array[Vector2i]:
	var neighbors: Array[Vector2i] = []
	var current_ring_segments_nb = get_segment_count(ring)
	
	# For outer ring neighbors
	if ring < rings_nb - 2:
		var outer_segments_nb = get_segment_count(ring + 1)
		
		if current_ring_segments_nb != outer_segments_nb:
			var child_segment = segment * 2
			
			if not visited[ring + 1][child_segment]:
				neighbors.append(Vector2i(ring + 1, child_segment))
			if not visited[ring + 1][child_segment + 1]:
				neighbors.append(Vector2i(ring + 1, child_segment + 1))
		elif ring != 0:
			var child_segment = segment
			if not visited[ring + 1][child_segment]:
				neighbors.append(Vector2i(ring + 1, child_segment))
		else:
			for i in range(outer_segments_nb):
				neighbors.append(Vector2i(ring + 1, i))
	
	# For inner ring neighbors
	if ring > 1:
		var inner_segments_nb = get_segment_count(ring - 1)
		var parent_segment = segment / 2 if current_ring_segments_nb != inner_segments_nb else segment
		
		if not visited[ring - 1][parent_segment]:
			neighbors.append(Vector2i(ring - 1, parent_segment))
	elif ring > 0:
		var parent_segment = 0
		if not visited[ring - 1][parent_segment]:
			neighbors.append(Vector2i(ring - 1, parent_segment))
	
	# Add the left and right segment neighbors in the same ring
	if ring != (rings_nb - 1):
		var left_segment = (segment - 1 + current_ring_segments_nb) % current_ring_segments_nb
		if not visited[ring][left_segment]:
			neighbors.append(Vector2i(ring, left_segment))
		
		var right_segment = (segment + 1) % current_ring_segments_nb
		if not visited[ring][right_segment]:
			neighbors.append(Vector2i(ring, right_segment))
	
	return neighbors

func is_path_open(ring1: int, segment1: int, ring2: int, segment2: int) -> bool:
	var segments_nb = get_segment_count(ring1)
	var cell1 = cells[ring1][segment1]
	var cell2 = cells[ring2][segment2]
	
	# If they are in the same ring
	if ring1 == ring2 and ring1 != rings_nb - 1:
		if segment1 == (segment2 + 1) % segments_nb:  # cell2 is to the left of cell1
			return cell1.left_node.visible
		elif segment2 == (segment1 + 1) % segments_nb:  # cell1 is to the left of cell2
			return cell2.left_node.visible
	# If they are in adjacent rings
	else:
		if ring1 < ring2:  # cell2 is outside cell1
			return cell2.front_node.visible
		else:  # cell1 is outside cell2
			return cell1.front_node.visible
	
	return false

func remove_wall_between(ring1: int, segment1: int, ring2: int, segment2: int) -> void:
	var segments_nb = get_segment_count(ring1)
	var cell1 = cells[ring1][segment1]
	var cell2 = cells[ring2][segment2]
	
	# If they are in the same ring
	if ring1 == ring2 and ring1 != rings_nb - 1:
		if segment1 == (segment2 + 1) % segments_nb:  # cell2 is to the left of cell1
			cell1.set_left(false)
		elif segment2 == (segment1 + 1) % segments_nb:  # cell1 is to the left of cell2
			cell2.set_left(false)
	# If they are in adjacent rings
	else:
		if ring1 < ring2:  # cell2 is outside cell1
			cell2.set_front(false)
		else:  # cell1 is outside cell2
			cell1.set_front(false)

# Shuffle array using Fisher-Yates shuffle
func shuffle_array(array: Array) -> void:
	var n = array.size()
	while n > 1:
		n -= 1
		var k = rng.randi() % (n + 1)
		var value = array[k]
		array[k] = array[n]
		array[n] = value

func get_segment_count(ring_index: int) -> int:
	return cells[ring_index].size()
