extends CharacterBody3D
class_name PlayerControler

@export var speed : float = 15
@export var accelaration : float = 15
@export var air_accelaration : float = 5
@export var gravity : float = 0.98
@export var jump_power : float = 20
@export_range(0.1, 1) var mouse_sensitivity: float = 0.5
@export_range(-90, 0) var min_pitch : float = -75
@export_range(0, 90) var max_pitch : float = 75

@export var beacon_count: int = 10
var currrent_beacon_count: int = 0
var beacons = []

var y_velocity : float

@onready var camera = $Camera3D
@onready var gui : PlayerGui = $Gui
@onready var col_manager : CollisionManager = $CollisionManager
@onready var becon = preload("res://Scenes/beacon.tscn")
var game_manager : GameManager

func _ready() -> void:
	game_manager = get_tree().get_first_node_in_group("GameManager")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta) -> void:
	#places the beacon node
	if Input.is_action_just_pressed("placeBeacon"):
		place_beacon()
	
	#interact with bed ojb
	if Input.is_action_just_pressed("interact"):
		if(col_manager.is_near_bed()):
			if col_manager.all_collected():
				game_manager.next_day()
			else:
				gui.update_objective("The fire will extinguish. \n I need the flames to survive",2)
			

func place_beacon():
	if currrent_beacon_count >= beacon_count:
		return
		
	var beaconObj :Node3D = becon.instantiate()
	beaconObj.translate(global_position + Vector3(0,0.05,0)) 
	beaconObj.name = "Beacon%d" %currrent_beacon_count
	get_tree().root.get_child(0).add_child(beaconObj)
	currrent_beacon_count += 1
	beacons.append(beaconObj)
	gui.update_beacon_counter("%d" % (beacon_count-currrent_beacon_count))

func remove_all_beacons():
	currrent_beacon_count = 0
	for beacon in beacons:
		beacon.queue_free()
	
	beacons = []
	

func _input(event) -> void:
	#handles camera to mouse movement conversion
	if event is InputEventMouseMotion:
		var mouse_sens_rad = mouse_sensitivity * 0.01
		rotation.y -= event.relative.x * mouse_sens_rad
		camera.rotation.x -= event.relative.y * mouse_sens_rad
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(min_pitch), deg_to_rad(max_pitch))

func _physics_process(delta) -> void:
	handle_movement(delta)

func handle_movement(delta) -> void:
	var direction = Vector3()
	
	if Input.is_action_pressed("forward"):
		direction -= transform.basis.z
		
	if Input.is_action_pressed("down"):
		direction += transform.basis.z
		
	if Input.is_action_pressed("left"):
		direction -= transform.basis.x
		
	if Input.is_action_pressed("right"):
		direction += transform.basis.x
		
	direction = direction.normalized()
	
	var accel = accelaration if is_on_floor() else air_accelaration
	
	# Separate horizontal and vertical velocity
	var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)
	horizontal_velocity = horizontal_velocity.lerp(direction * speed, accel * delta)
	
	# Apply horizontal velocity
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z
	
	# Handle vertical movement
	if is_on_floor():
		y_velocity = -0.1  # Small constant downward force when on floor
	else:
		y_velocity = y_velocity - gravity * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		y_velocity = jump_power
		
	velocity.y = y_velocity
	move_and_slide()
	
