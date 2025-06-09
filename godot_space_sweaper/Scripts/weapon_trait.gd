extends Node
class_name Weapon_Trait

@export var bullet_scene: PackedScene
@export var fire_rate: float = 2.0              # 射速 (每秒发射次数)
@export var projectiles_per_shot: int = 1       # 每次发射的弹丸数量
@export var shoot_area_path: NodePath           # 发射口位置（Node2D）

func set_weapon_trait_data(shooting_area : NodePath, bullet : PackedScene, firerate: float, projectilespershot : int):
	shoot_area_path = shooting_area
	bullet_scene = bullet
	fire_rate = firerate
	projectiles_per_shot = projectilespershot
	
func _init(shooting_area : NodePath, bullet : PackedScene, firerate: float, projectilespershot : int) -> void:
	set_weapon_trait_data(shooting_area, bullet, firerate, projectilespershot)
