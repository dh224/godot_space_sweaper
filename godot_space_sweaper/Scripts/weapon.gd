extends Node2D
class_name Weapon

@export var bullet_scene: PackedScene
@export var fire_rate: float = 2.0              # 射速 (每秒发射次数)
@export var projectiles_per_shot: int = 1       # 每次发射的弹丸数量
@export var shoot_area_path: NodePath           # 发射口位置（Node2D）
@export var weapon_texture : Texture2D
@export var weapon_name: String

func get_weapon_trait() -> Weapon_Trait:
	var wd = Weapon_Trait.new(shoot_area_path, bullet_scene, fire_rate, projectiles_per_shot )
	return wd

func get_weapon_texture() -> Texture2D:
	return weapon_texture

func shoot():
	var shoot_position: Vector2
	if has_node(shoot_area_path):
		shoot_position = get_node(shoot_area_path).global_position
	else:
		shoot_position = global_position

	for i in range(projectiles_per_shot):
		var bullet = bullet_scene.instantiate()
		if bullet is Node2D:
			bullet.global_position = shoot_position
			get_tree().current_scene.add_child(bullet)
		else:
			push_error("bullet_scene 不是 Node2D 类型，无法设置位置")
