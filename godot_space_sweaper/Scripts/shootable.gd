extends Node2D
class_name Shootable
@export var bullet_scene: PackedScene
@export var fire_rate: float = 10.0              # 射速 (每秒发射次数)
@export var projectiles_per_shot: int = 1       # 每次发射的弹丸数量
@export var shoot_area_path: NodePath           # 发射口位置（Node2D）

@export var weapon_slot : Array[Weapon]


var current_weapon_index : int
var current_weapon : Weapon
var _cooldown_timer := 0.0

func _ready():
	if shoot_area_path == NodePath(""):
		push_warning("shoot_area_path 未设置，默认使用自身位置")
	current_weapon = weapon_slot[0]
	current_weapon_index = 0
	set_process(true)

func _process(delta):
	_cooldown_timer -= delta

func can_shoot() -> bool:
	return _cooldown_timer <= 0.0

func change_next_weapon() -> String:
	if weapon_slot.size() == 1:
		return weapon_slot[0].weapon_name
	current_weapon_index = (current_weapon_index + 1) % weapon_slot.size()
	var next_weapon = weapon_slot[current_weapon_index]
	set_current_weapon(next_weapon)
	return next_weapon.weapon_name

func set_current_weapon(new_weapon : Weapon):
	var weapon_trait = new_weapon.get_weapon_trait()
	bullet_scene = weapon_trait.bullet_scene
	fire_rate = weapon_trait.fire_rate
	projectiles_per_shot = weapon_trait.projectiles_per_shot
	shoot_area_path = weapon_trait.shoot_area_path
	current_weapon = new_weapon
	UI.set_weapon_texture(new_weapon.get_weapon_texture())

func shoot() ->bool :
	if not can_shoot():
		return false
	current_weapon.shoot()
	_cooldown_timer = get_shot_cooldown()
	return true

func get_shot_cooldown() -> float:
	if fire_rate <= 0:
		return 0.01  # 防止除以 0
	return 1.0 / fire_rate
