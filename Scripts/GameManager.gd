extends Node
class_name GameManager

@export var max_time: float = 5.0  # Time in seconds
var time_left: float
var current_stage: float = 0
@export var number_of_fires: int  = 5
var current_day: int = 0
var last_day : int = 1

@onready var fire_place_script : FirePlaceManager = $"../FirePlace"
@onready var maze_manager : MazeManager = $".."
@onready var collision_manager : CollisionManager = $"../Player/CollisionManager"

@onready var player = $"../Player"
@onready var player_controler : PlayerControler = $"../Player"
@onready var player_gui : PlayerGui = $"../Player/Gui"

@onready var clock_sfx : AudioStreamPlayer3D = $"../ClockTicking"
@onready var ambient : AudioStreamPlayer3D = $"../Player/SoundManager/Ambinet"


func _ready() -> void:
	time_left = max_time
	current_stage = number_of_fires

func _process(delta: float) -> void:
	if time_left > 0:
		time_left -= delta
		player_gui.update_timer_value(floor(time_left))
		
		if floor(time_left) < 45:
			play_ticking_sound()
		else:
			stop_ticking_sound()
		
		if floor(time_left) != floor(time_left + delta):
			if(floor(time_left) < (max_time/number_of_fires) * current_stage):
				current_stage -= 1
				fire_place_script.update_fire_particles(remap(current_stage, 0, number_of_fires, 1, 2))
				
				
	elif time_left <= 0 and time_left + delta > 0:  # Check if we just hit zero this frame
		print("Time's up!")
		stop_ticking_sound()
		fire_place_script.hide_fireplace_fire()
		player_gui.game_over()
		ambient.stop()
		
func reset_game():
	stop_ticking_sound()
	maze_manager.regenerate_maze(number_of_fires)
	player.remove_all_beacons()
	fire_place_script.show_fireplace_fire()
	player.global_position = Vector3(0,0,0)

func next_day():
	if(current_day != last_day):
		number_of_fires *= 2
		max_time += 60
		time_left = max_time
		collision_manager.set_max_collectable_count(number_of_fires)
		player_gui.next_stage(false)
		reset_game()
		current_day += 1
	else:
		ambient.stop()
		player_gui.next_stage(true)

func restart_game():
	get_tree().reload_current_scene()
	
func add_time(value : float):
	if(current_day == last_day):
		time_left += value * 1.5
	else:
		time_left += value

func play_ticking_sound():
	if !clock_sfx.playing:
		clock_sfx.play()

func stop_ticking_sound():
	if clock_sfx.playing:
		clock_sfx.stop()
