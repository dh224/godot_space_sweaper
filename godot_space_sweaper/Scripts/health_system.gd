extends Node2D
class_name Health
@export var health : int = 4

signal killed()
signal hited()

func take_damage(count : float):
	var mod = 1
	if health > count * mod:
		health -= round(count * mod)
	else:
		health = 0
		emit_signal("killed")
		
