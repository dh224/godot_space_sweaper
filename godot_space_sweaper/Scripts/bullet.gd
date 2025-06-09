class_name BaseBullet
extends Area2D

signal hit_target(target_body, bullet_instance) # 当击中目标时发出
const EXPLOSION_SCENE = preload("res://Scenes/particle_explosion.tscn") 

@export var speed: float = 1500.0
@export var damage: float = 5.0
@export var direction: Vector2 = Vector2.RIGHT # 默认为玩家射击方向
@export var lifetime: float = 2.0 # 子弹存活时间 (秒)
@export var hit_sound : AudioStreamPlayer2D

# 哪些目标类型是此子弹的“有效”目标 (造成额外效果或伤害)
@export var effective_against_types: Array[GlobalEnums.TargetType] = []
@export var effectiveness_multiplier: float = 2.0 # 对有效目标的效果倍率

# 特殊效果标识 (可选, 用于更复杂的逻辑)
# enum SpecialEffect { NONE, PIERCING, EXPLOSIVE, SLOW }
# export(SpecialEffect) var special_effect = SpecialEffect.NONE
@export var is_piercing: bool = false
var pierce_count: int = 1 # 如果是穿透弹，能穿透多少个

func _ready():
	# 连接碰撞信号
	var timer = Timer.new()
	timer.wait_time = lifetime
	timer.one_shot = true
	timer.timeout.connect(func(): queue_free())
	add_child(timer)
	timer.start()
	
func _physics_process(delta: float):
	position += direction * speed * delta



	# 检查 body 是否是我们关心的目标 (例如，是否有 take_damage 方法或在特定组)
	#if body.has_method("take_damage"):
		#var actual_damage = damage
		#var is_effective = false
#
		#if body.has_method("get_target_type"): # 目标需要有这个方法
			#var target_type = body.get_target_type()
			#if target_type in effective_against_types:
				#actual_damage *= effectiveness_multiplier
				#is_effective = true
				#print(str(self.name) + " is super effective against " + str(body.name))
#
#
		## 发射信号，让游戏逻辑处理伤害和效果
		#emit_signal("hit_target", body, self) # 传递自身实例，以便获取更多信息
		## 应用伤害 (也可以在 Game Manager 中处理，通过信号传递)
		#body.take_damage(actual_damage, self) # 传递子弹实例，目标可以知道是什么子弹打的
#
		## 处理穿透
		##if is_piercing:
			##pierce_count -= 1
			##if pierce_count <= 0:
				##queue_free()
		##else:
		#queue_free() # 普通子弹击中后销毁

# 可被外部调用以设置子弹属性
func setup(pos: Vector2, dir: Vector2, custom_props: Dictionary = {}):
	global_position = pos
	direction = dir.normalized()
	# 可以从 custom_props 覆盖导出变量
	if "speed" in custom_props: speed = custom_props.speed
	if "damage" in custom_props: damage = custom_props.damage
	# ... 等等


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Target"):
		if area.has_method("take_damage"):
			var explosion_instance = EXPLOSION_SCENE.instantiate()
			# 获取当前场景树根节点（最安全的父节点添加方式）
			var root_node = get_tree().root
			UI.gun_hit_sound.play()
			# 在击中位置附近生成随偏移量
			var random_offset = Vector2(
				randf_range(0, 30),  # X轴随机偏移 -20到20像素
				randf_range(-25, 25)   # Y轴随机偏移 -20到20像素
			)
			
			root_node.add_child(explosion_instance)
			# 设置粒子效果位置为击中位置+随机偏移
			explosion_instance.global_position = global_position + random_offset
			area.take_damage(damage, GlobalEnums.BulletType.NORMAL)
			queue_free()
	
