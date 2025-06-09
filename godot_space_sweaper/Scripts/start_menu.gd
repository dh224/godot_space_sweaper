extends Control

@onready var earth = $地球
@onready var meteor = $陨石
@onready var spaceship = $宇宙飞船
@onready var panelContainer = $PanelContainer
@onready var jupyter = $"木星"
@onready var hover_sound = $BGM2
@onready var press_sound = $BGM3

# 偏移强度（越小越远）
const EARTH_STRENGTH = 0.002
const METEOR_STRENGTH = 0.01
const SHIP_STRENGTH = 0.08
const JUPYTER_STRENGTH = 0.001
# 初始位置
var earth_origin := Vector2.ZERO
var meteor_origin := Vector2.ZERO
var spaceship_origin := Vector2.ZERO
var jupyter_origin := Vector2.ZERO
func _ready():
	# 记录初始位置
	earth_origin = earth.position
	meteor_origin = meteor.position
	spaceship_origin = spaceship.position
	jupyter_origin = jupyter.position
	UI.visible = false

func _process(delta):
	var viewport_size = get_viewport().get_visible_rect().size
	var mouse_pos = get_viewport().get_mouse_position()
	var center = viewport_size / 2
	var offset = mouse_pos - center

	# 基于原始位置添加偏移
	earth.position = earth_origin + offset * EARTH_STRENGTH
	meteor.position = meteor_origin + offset * METEOR_STRENGTH
	spaceship.position = spaceship_origin + offset * SHIP_STRENGTH
	jupyter.position = jupyter_origin + offset * JUPYTER_STRENGTH


func _on_开始游戏_button_down() -> void:
	play_press_sound()
	await get_tree().create_timer(0.75).timeout
	print(1)
	get_tree().change_scene_to_file("res://Scenes/game.tscn")

func play_hover_sound() -> void:
	hover_sound.play()

func play_press_sound() -> void:
	press_sound.play()

func _on_开始游戏_mouse_entered() -> void:
	play_hover_sound()


func _on_最高记录_mouse_entered() -> void:
	play_hover_sound()


func _on_最高记录_button_down() -> void:
	play_press_sound()
	await get_tree().create_timer(0.75)


func _on_退出游戏_button_down() -> void:
	play_press_sound()
	await get_tree().create_timer(0.85).timeout
	get_tree().quit()


func _on_退出游戏_mouse_entered() -> void:
	play_hover_sound()
