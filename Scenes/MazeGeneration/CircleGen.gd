extends Node3D

@export var inner_radius: float = 4.5  # radius of inner wall (distance from center)
@export var outer_radius: float = 5.0  # radius of outer wall (distance from center)
@export var angle: float = 360.0  # angle of the curve
@export var wall_height: float = 3.0  # height of the wall
@export var segments: int = 20  # how many polygons (LOD)
@export var material: Material  # wall material


func generate_mesh() -> void:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	if material:
		st.set_material(material)
	
	var angle_step = angle / segments
	var radian_step = deg_to_rad(angle_step)
	
	for i in range(segments + 1):
		var current_angle = radian_step * i
		
		var cos_angle = cos(current_angle)
		var sin_angle = sin(current_angle)
		
		var x_inner = sin_angle * inner_radius
		var z_inner = cos_angle * inner_radius
		var x_outer = sin_angle * outer_radius
		var z_outer = cos_angle * outer_radius
		
		# Calculate normals (now pointing outward)
		var inner_normal = Vector3(x_inner, 0, z_inner).normalized()  # Removed the -1 multiplication
		var outer_normal = Vector3(x_outer, 0, z_outer).normalized()
		
		var v0 = Vector3(x_inner, 0, z_inner)
		var v1 = Vector3(x_inner, wall_height, z_inner)
		var v2 = Vector3(x_outer, 0, z_outer)
		var v3 = Vector3(x_outer, wall_height, z_outer)
		
		if i < segments:
			var next_angle = radian_step * (i + 1)
			var next_sin = sin(next_angle)
			var next_cos = cos(next_angle)
			
			var next_x_inner = next_sin * inner_radius
			var next_z_inner = next_cos * inner_radius
			var next_x_outer = next_sin * outer_radius
			var next_z_outer = next_cos * outer_radius
			
			var v4 = Vector3(next_x_inner, 0, next_z_inner)
			var v5 = Vector3(next_x_inner, wall_height, next_z_inner)
			var v6 = Vector3(next_x_outer, 0, next_z_outer)
			var v7 = Vector3(next_x_outer, wall_height, next_z_outer)
			
			# Inner wall (reversed vertex order for correct facing)
			add_quad(st, v0, v4, v5, v1, -inner_normal)
			
			# Outer wall
			add_quad(st, v2, v3, v7, v6, outer_normal)
			
			# Top wall
			add_quad(st, v1, v5, v7, v3, Vector3.UP)
			
			# Bottom wall
			add_quad(st, v0, v2, v6, v4, Vector3.DOWN)

	# Add end caps with correct normal directions
	var start_inner = Vector3(0, 0, inner_radius)
	var start_inner_top = Vector3(0, wall_height, inner_radius)
	var start_outer = Vector3(0, 0, outer_radius)
	var start_outer_top = Vector3(0, wall_height, outer_radius)
	
	var end_angle = deg_to_rad(angle)
	var end_inner = Vector3(sin(end_angle) * inner_radius, 0, cos(end_angle) * inner_radius)
	var end_inner_top = Vector3(sin(end_angle) * inner_radius, wall_height, cos(end_angle) * inner_radius)
	var end_outer = Vector3(sin(end_angle) * outer_radius, 0, cos(end_angle) * outer_radius)
	var end_outer_top = Vector3(sin(end_angle) * outer_radius, wall_height, cos(end_angle) * outer_radius)
	
	# Start cap (facing start direction)
	add_quad(st, start_inner, start_inner_top, start_outer_top, start_outer, Vector3(0, 0, -1))
	
	# End cap (facing end direction)
	add_quad(st, end_inner_top, end_inner, end_outer, end_outer_top, Vector3(0, 0, 1))
	
	var mesh = st.commit()
	
	var mesh_instance = get_node_or_null("MeshInstance3D")
	if not mesh_instance:
		mesh_instance = MeshInstance3D.new()
		mesh_instance.name = "MeshInstance3D"
		add_child(mesh_instance)
	
	mesh_instance.mesh = mesh
	
	var collision_shape = get_node_or_null("CollisionShape3D")
	if not collision_shape:
		collision_shape = CollisionShape3D.new()
		collision_shape.name = "CollisionShape3D"
		var static_body = StaticBody3D.new()
		static_body.name = "StaticBody3D"
		add_child(static_body)
		static_body.add_child(collision_shape)
	
	collision_shape.shape = mesh.create_trimesh_shape()

# Helper function to add a quad (two triangles) to the surface tool
func add_quad(st: SurfaceTool, v0: Vector3, v1: Vector3, v2: Vector3, v3: Vector3, normal: Vector3) -> void:
	st.set_normal(normal)
	st.add_vertex(v0)
	st.add_vertex(v1)
	st.add_vertex(v2)
	
	st.add_vertex(v0)
	st.add_vertex(v2)
	st.add_vertex(v3)
