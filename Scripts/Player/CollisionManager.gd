extends Node
class_name CollisionManager

@onready var light_source : Light3D = $"../OmniLight3D"
@onready var gui : PlayerGui = $"../Gui"
@onready var pickupSound :AudioStreamPlayer3D  = $"../SoundManager/PickUp"

var light: Light3D;
var near_bed : bool

var all_lights_collected: bool
var current_collectable_count: int = 0

@export var max_collectables: int = 5
@export var collectable_value : int = 10 #the value that gets added to the timer

var game_manager : GameManager

func _ready() -> void:
	gui.update_fire_counter("%d/%d" % [current_collectable_count , max_collectables])
	game_manager = get_tree().get_first_node_in_group("GameManager")


func handle_light_strenght():
	light_source.light_energy  += current_collectable_count * 3
	
func _on_area_3d_area_entered(area: Area3D) -> void:
	# Check if the body is in the "collectable" group
	if area.is_in_group("collectable"):
		current_collectable_count += 1
		game_manager.add_time(collectable_value); # add more time to timer
		handle_light_strenght()
		gui.update_fire_counter("%d/%d" % [current_collectable_count , max_collectables])
		pickupSound.play()
		# Destroy the collectable
		area.queue_free()
		
		if current_collectable_count == max_collectables:
			all_lights_collected = true
			gui.update_objective("i've got enough.\nlet's go home. I need to sleep", 5)
		
	if area.is_in_group("sleepable"):
		near_bed = true
		gui.set_interation_visability(true)


func _on_area_3d_area_exited(area: Area3D) -> void:
	# Check if the body is in the "sleepables" group
	if area.is_in_group("sleepable"):
		near_bed = false
		gui.set_interation_visability(false)

func is_near_bed() -> bool:
	return near_bed

func all_collected() -> bool:
	return all_lights_collected
	
func set_max_collectable_count(new_value : int):
	max_collectables = new_value
	current_collectable_count = 0
	gui.update_fire_counter("%d/%d" % [current_collectable_count , max_collectables])
