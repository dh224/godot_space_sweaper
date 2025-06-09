# GameOverUI.gd
extends Control
class_name Game_Over_Panel

@onready var panel = $Panel
@onready var restart_button = $Panel/Button
@onready var quit_button = $Panel/Button2

@export var dead_text : Label

func _ready():
	# 初始设置为不可见 + 透明
	visible = false
	panel.modulate.a = 0.0

	restart_button.pressed.connect(_on_restart_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	restart_button.process_mode = Node.PROCESS_MODE_ALWAYS
	quit_button.process_mode = Node.PROCESS_MODE_ALWAYS

func fade_in_and_pause():
	visible = true
	var tween = create_tween()
	tween.tween_property(
		panel,
		"modulate:a",
		1.0,
		0.2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(Callable(self, "_pause_game"))
	
func _pause_game():
	get_tree().paused = true
	
func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()
	UI.reset_game_state()

func _on_quit_pressed():
	get_tree().quit()

func set_text(text : String):
	dead_text.text = text
	pass
