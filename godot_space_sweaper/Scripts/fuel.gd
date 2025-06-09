extends Node
class_name Fuel

@export var fuel_amount : float = 100.0 :
	set(value):
		fuel_amount = value
		UI.set_fuel_bar(get_fuel_rate())
		UI.set_fuel_amount_rate(get_fuel_rate())
@export var fuel_capacity : float = 100
@export var fuel_level : int = 100 # %
@export var fuel_consumption_rate : float = 1 # 1 / s
@export var fuel_consumption_modifyer : float = 1 
@export var fuel_change_chanel_consumption : float = 5

@export var fuel_started := false

signal fuel_dead

func _process(delta: float) -> void:
	if fuel_started:
		fuel_amount -= fuel_consumption_rate * delta * fuel_consumption_modifyer
		if fuel_amount < 0.001:  # Godot提供的浮点近似判断
			emit_signal("fuel_dead")
		
func get_fuel_rate():
	return  round((fuel_amount / fuel_capacity) * 100.0)
	
func change_fuel(number : float):
	if fuel_started:
		fuel_amount += number

func add_fuel(number: float):
	change_fuel(number)

func minus_fuel(number : float):
	change_fuel(-number)

func fuel_start():
	fuel_started = true

func fuel_change_chanel(chanel : int):
	minus_fuel(fuel_change_chanel_consumption)
	if chanel == 0:
		fuel_consumption_modifyer = 0.75
	elif chanel == 1:
		fuel_consumption_modifyer = 1
	elif chanel == 2:
		fuel_consumption_modifyer = 1.5
