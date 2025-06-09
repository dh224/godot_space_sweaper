extends Control
class_name GameUI


@export_category("生命条")
const HELATH_BAR_NUMBER_MAX = 4
@export var health_bar_rect : TextureRect

@export var gun_hit_sound : AudioStreamPlayer2D
@export var rocket_hit_sound : AudioStreamPlayer2D

var health_bar_texture : Texture2D 

var health_bar_region_array : Array[Rect2] = [
	Rect2(0,32,16,16), #0
	Rect2(16,64,16,16), #1
	Rect2(48,64,16,16), #2
	Rect2(80,64,16,16), #3
	Rect2(112,64,16,16), #4
]

var health_bar_number : int

@export_category("燃料系统")

@export var fuel_process_bar : TextureProgressBar
@export var fuel_amount_rate_text : Label
@export var fuel_consumption_rate_text : Label

@export_category("击杀系统")
@export var asteroid_killed : Label
@export var meteor_killed : Label
@export var nut_killed : Label
@export var glove_killed : Label
@export var orbitor_killed : Label
@export var probe_killed : Label

var asteroid_killed_number : int = 0
var meteor_killed_number : int = 0
var nut_killed_number : int = 0
var glove_killed_number : int = 0
var orbitor_killed_number : int = 0
var probe_killed_number : int = 0

@export_category("武器槽")
@export var weapon_texture : TextureRect

func _ready() -> void:
	var texture = health_bar_rect.texture
	health_bar_texture = texture
	health_bar_number = HELATH_BAR_NUMBER_MAX
	set_health_bar(HELATH_BAR_NUMBER_MAX)
		
		
func set_health_bar(number : int) -> void:
	health_bar_rect.texture.region = health_bar_region_array[number]
	health_bar_number = number
	print(health_bar_rect.texture.region)
	
func add_health(number : int) -> void:
	print("增加")
	
	if health_bar_number + number > HELATH_BAR_NUMBER_MAX:
		health_bar_number = HELATH_BAR_NUMBER_MAX
		
	else:
		health_bar_number += number
		set_health_bar(health_bar_number)

func minus_health(number : int) -> void:
	print("减少")
	if health_bar_number - number > 0:
		health_bar_number -= number
		set_health_bar(health_bar_number)
	else:
		health_bar_number = 0
		set_health_bar(health_bar_number)
		# 结束游戏
	


# fuel
func set_fuel_bar(number : int) -> void:
	fuel_process_bar.value = number

func set_fuel_amount_rate(rate : int) -> void:
	fuel_amount_rate_text.text = str(rate) + " %"
	
func set_fuel_consumption_rate(index : int) -> void:
	if index == 0:
		fuel_consumption_rate_text.text = "低"
		fuel_consumption_rate_text.label_settings.font_color = Color.CORNFLOWER_BLUE
	elif  index == 1:
		fuel_consumption_rate_text.text = "中"
		fuel_consumption_rate_text.label_settings.font_color = Color.WHEAT
	elif index == 2:
		fuel_consumption_rate_text.text = "高"
		fuel_consumption_rate_text.label_settings.font_color = Color.CRIMSON


	
#killed
func killed_update_text(object_name: String) -> void:
	if object_name == "陨石":
		meteor_killed_number += 1
		meteor_killed.text = "× " + str(meteor_killed_number)
	elif object_name == "大陨石":
		asteroid_killed_number += 1
		asteroid_killed.text = "× " + str(asteroid_killed_number)
	elif object_name == "螺母" :
		nut_killed_number += 1
		nut_killed.text = "× " + str(nut_killed_number)
	elif object_name == "探测器" :
		probe_killed_number += 1
		probe_killed.text = "× " + str(probe_killed_number)
	elif object_name == "手套" :
		glove_killed_number += 1
		glove_killed.text = "× " + str(glove_killed_number)
	elif object_name == "卫星" :
		orbitor_killed_number += 1
		orbitor_killed.text = "× " + str(orbitor_killed_number)

func reset_killed_system() -> void :
	meteor_killed_number = 0
	nut_killed_number = 0
	asteroid_killed_number = 0
	probe_killed_number = 0
	glove_killed_number = 0
	orbitor_killed_number = 0
	meteor_killed.text = "× " + str(meteor_killed_number)
	asteroid_killed.text = "× " + str(asteroid_killed_number)
	nut_killed.text = "× " + str(nut_killed_number)
	probe_killed.text = "× " + str(probe_killed_number)
	glove_killed.text = "× " + str(glove_killed_number)
	orbitor_killed.text = "× " + str(orbitor_killed_number)

func reset_health_system() -> void:
	health_bar_number = 4
	set_health_bar(4)

func reset_fuel_system() -> void:
	pass

func reset_game_state() -> void:
	reset_killed_system() 
	reset_health_system()
	reset_fuel_system()

func set_weapon_texture(text : Texture2D) -> void:
	weapon_texture.texture = text


func _on_button_pressed() -> void:
	UI.reset_game_state()
	get_tree().change_scene_to_file("res://Scenes/start_menu.tscn")
