extends Node
class_name PlayerGui

@onready var fire_counter = $FiresColected/Count
@onready var objective_text =$ObjectiveText
@onready var timer_value =$TimerHeader/timerValue
@onready var interation_text = $InteractionText
@onready var black_screen = $LoadingScreen

@onready var win_screen = $Win
@onready var game_over_screen = $GameOver

@onready var win_screen_header = $Win/Header2
@onready var win_screen_restart_button = $Win/VBoxContainer/NextDay

@onready var beacon_counter = $BeaconsLeft/Count

var timer = Timer.new()

var game_manager : GameManager

func _ready() -> void:
	game_manager = get_tree().get_first_node_in_group("GameManager")
	
	#Start text
	objective_text.text = "It's getting cold. \nI need more fire"
	await get_tree().create_timer(5.0,false).timeout
	objective_text.text = "i have these 10 beacons "
	await get_tree().create_timer(2.0,false).timeout
	objective_text.text = " If i place them they can help me find my way back"
	await get_tree().create_timer(4.0,false).timeout
	objective_text.text = " look around - Mouse\n W/A/S/D - move \n Space - jump"
	await get_tree().create_timer(4.0,false).timeout
	objective_text.text = ""

func seconds_to_time_string(seconds: int) -> String:
	var minutes = seconds / 60
	var remaining_seconds = seconds % 60
	return "%02d:%02d" % [minutes, remaining_seconds]

func update_fire_counter(text : String):
	fire_counter.text = text
	
func update_beacon_counter(text : String):
	beacon_counter.text = text
	

func update_timer_value(count : int):
	timer_value.text = seconds_to_time_string(count)
	
func set_interation_visability(state : bool):
	if state:
		interation_text.show()
	else:
		interation_text.hide()

func set_screen_to_black(state : bool):
	if state:
		black_screen.show()
	else:
		black_screen.hide()

func update_objective(text : String, showTime: float = 3):
	objective_text.text = text
	await get_tree().create_timer(showTime,false).timeout
	objective_text.text = ""

func game_over():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	game_over_screen.show()
	
func next_stage(last_stage:bool):
	if last_stage:
		print("game ended")
		interation_text.hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		win_screen.show()
		win_screen_header.text = "You won the game"
		win_screen_restart_button.hide()
	else:
		print("next day")
		interation_text.hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		win_screen.show()
		win_screen_header.text = "You survied the day"
		win_screen_restart_button.show()

func _on_next_day_pressed() -> void:
	game_manager.next_day()
	win_screen.hide()
	game_over_screen.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_restart_pressed() -> void:
	game_manager.restart_game()

	
func _on_exit_pressed() -> void:
	get_tree().quit()
	
func win_screen_active() -> bool:
	return win_screen.is_visible_in_tree()

func game_over_screen_active() -> bool:
	return game_over_screen.is_visible_in_tree()
