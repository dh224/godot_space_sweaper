extends Node2D
class_name Meteor
@export var health : float = 10
@export var is_move_on :bool = true
@export var move_speed = 100
@export var meteor_name : String = "陨石"
@export var crash_damage := 1

signal died(name : String, was_killed : bool)

func _physics_process(delta: float) -> void:
	global_position.x -= move_speed * delta
	if global_position.x < -80:
		print("自行销毁了")
		health = 0
		dead()

func take_damage(count : float, bullet_type : GlobalEnums.BulletType):
	var mod = 1
	if bullet_type == GlobalEnums.BulletType.NORMAL:
		mod = 1
	elif bullet_type == GlobalEnums.BulletType.ROCKET:
		mod = 2
	elif bullet_type == GlobalEnums.BulletType.RECYCLE:
		mod = 0.25
	
	if health > count * mod:
		health -= count * mod
	else:
		health = 0
		killed()
		
func killed() ->void:
	emit_signal("died", meteor_name,true)
	queue_free()
	pass
	
func dead() -> void :
	emit_signal("died", meteor_name, false)
	queue_free()
	pass


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Ship"):
		if area.get_parent().has_method("take_damage"):
			area.get_parent().take_damage(crash_damage)
			queue_free()
