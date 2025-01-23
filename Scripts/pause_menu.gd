extends Node

@onready var pause_panel = $Panel
@onready var player_gui : PlayerGui = $"../Player/Gui"

func resume():
	get_tree().paused = false
	pause_panel.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func pause():
	get_tree().paused = true
	pause_panel.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func pause_input():
	if Input.is_action_just_pressed("pause") and !get_tree().paused:
		if player_gui.win_screen_active() || player_gui.game_over_screen_active():
			return
		pause()
	elif Input.is_action_just_pressed("pause") and get_tree().paused:
		resume()


func _on_resume_pressed():
	resume()

func _process(delta):
	pause_input()

func _on_exit_pressed() -> void:
	get_tree().quit()
