extends Node2D

# Paths to the Marker2D nodes defining the orbit Y positions
@export var high_orbit_marker_path: NodePath
@export var mid_orbit_marker_path: NodePath
@export var low_orbit_marker_path: NodePath

@export var animatedSprite : AnimatedSprite2D

@export var tween_duration: float = 0.4  # 切换动画的总时长 (秒)

@export var tween_transition_type: Tween.TransitionType = Tween.TRANS_ELASTIC

@export var tween_ease_type: Tween.EaseType = Tween.EASE_IN_OUT

@export var shootable : Shootable



@export var is_switching_line : bool = false

@export var fuel_system : Fuel

@export var health_system : Health

@export var camera_system : Camera2D

@export var game_over_panel : Game_Over_Panel

@export var ship_hit_sound : AudioStreamPlayer2D


@export var ship_change_weapon_sound : AudioStreamPlayer2D
@export var gun_shoot_sound : AudioStreamPlayer2D
@export var rocket_shoot_sound : AudioStreamPlayer2D

var current_weapon_name := "Gun"

# --- 内部变量 (Internal Variables) ---
var lane_y_positions: Array[float] = []  # 存储轨道的Y轴坐标
var current_lane_index: int = 1          # 0:高轨, 1:中轨, 2:低轨 (初始轨道)
var current_tween: Tween                 # 保存当前活动的轨道切换Tween

# --- Godot 生命周期方法 (Lifecycle Methods) ---
func _ready():
	# 1. 从 Marker2D 节点获取并存储轨道的Y轴位置
	var high_marker = get_node_or_null(high_orbit_marker_path)
	var mid_marker = get_node_or_null(mid_orbit_marker_path)
	var low_marker = get_node_or_null(low_orbit_marker_path)
	UI.visible = true
	# 建立信号
	fuel_system.connect("fuel_dead", Callable(self, "_on_fuel_died"))
	health_system.connect("killed", Callable(self, "on_ship_dead"))
	health_system.connect("hited", Callable(self, "on_ship_hited"))

	
	if not (high_marker and mid_marker and low_marker):
		# 根据视口高度定义默认轨道位置
		var viewport_height = get_viewport_rect().size.y
		lane_y_positions = [
			viewport_height * 0.25, 
			viewport_height * 0.50, 
			viewport_height * 0.75  
		]
	else:
		lane_y_positions = [
			high_marker.global_position.y,
			mid_marker.global_position.y,
			low_marker.global_position.y
		]

	# 2. 根据 current_lane_index 设置飞船的初始Y轴位置
	if not lane_y_positions.is_empty() and \
	   current_lane_index >= 0 and current_lane_index < lane_y_positions.size():
		global_position.y = lane_y_positions[current_lane_index]
	else:
		if lane_y_positions.is_empty():
			printerr("错误: Ship - 设置后轨道Y轴位置数组为空。")
		else:
			printerr("错误: Ship - 初始 current_lane_index 超出范围。")
		# 如果初始化失败，则回退到屏幕中央
		global_position.y = get_viewport_rect().size.y / 2

	# 为飞船设置一个固定的X轴位置 (例如，在屏幕左侧)
	global_position.x = 150 # 根据需要调整此值
	
	#初始化为中间轨道
	fuel_system.fuel_change_chanel(1)
	UI.set_fuel_consumption_rate(1)
	fuel_system.fuel_start()
	

func _on_fuel_died() -> void:
	print("测试")
	game_over_panel.set_text("很遗憾，你因燃料耗尽，任务暂停")
	game_over_panel.fade_in_and_pause()

func _unhandled_input(event: InputEvent) -> void:
	# 忽略鼠标移动或屏幕拖动事件
	if event is InputEventMouseMotion or event is InputEventScreenDrag:
		return
	

	if event is InputEventKey and event.pressed and not event.echo:
		if Input.is_action_just_pressed("move_up"):
			switch_lane(-1)
			get_viewport().set_input_as_handled()

		elif Input.is_action_just_pressed("move_down"):
			switch_lane(1)
			get_viewport().set_input_as_handled()
		elif Input.is_action_just_pressed("fire") and !is_switching_line:
			if shootable.shoot():	
				if current_weapon_name == "Gun":
					gun_shoot_sound.play()
				elif current_weapon_name == "Rocket":
					rocket_shoot_sound.play()
			
		elif  Input.is_action_just_pressed("change_weapon"):
			current_weapon_name = shootable.change_next_weapon()
			ship_change_weapon_sound.play()
			
		#elif Input.is_action_just_pressed("add_health"):
			#UI.add_health(1)
		#elif Input.is_action_just_pressed("minus_health"):
			#UI.minus_health(1)
			#on_ship_hited()

# --- 自定义方法 (Custom Methods) ---
# 使用 tween 动画切换轨道的函数
func switch_lane(direction: int):
	var new_lane_index = current_lane_index + direction
	if is_switching_line :
		return
	
	# 将 new_lane_index 限制在可用轨道的有效范围内
	new_lane_index = clamp(new_lane_index, 0, lane_y_positions.size() - 1)
	print(new_lane_index == current_lane_index)
	# 仅当目标轨道与当前轨道不同，并且轨道位置已成功加载时才继续
	if new_lane_index != current_lane_index and not lane_y_positions.is_empty():
		is_switching_line = true
		current_lane_index = new_lane_index
		var target_y = lane_y_positions[current_lane_index]
		
		fuel_system.fuel_change_chanel(new_lane_index)
		UI.set_fuel_consumption_rate(new_lane_index)
		print(direction)
		# 如果当前有正在运行的轨道切换 tween，先将其终止
		# 这可以防止多个 tween 同时尝试对位置进行动画处理
		if current_tween and current_tween.is_valid() and current_tween.is_running():
			current_tween.kill() # 立即停止并使旧的 tween 失效
		#
		#if direction > 0:
			#animatedSprite.play("down")
		#elif direction < 0:
			#animatedSprite.play("up")
		
		# 创建一个新的 tween 实例
		# SceneTreeTween 会由 SceneTree 自动处理和释放
		current_tween = get_tree().create_tween()
		
		# 配置 tween 的过渡和缓动类型以实现 "juicy" 效果
		current_tween.set_trans(tween_transition_type)
		current_tween.set_ease(tween_ease_type)
		
		# 对此节点 ("Ship" Node2D) 的 'global_position:y' 属性进行动画处理
		# 'self' 指的是此脚本附加到的 "Ship" 节点。
		current_tween.tween_property(self, "global_position:y", target_y, tween_duration)

		# 可选: 为轨道切换播放音效
		#if switch_sound_player and switch_sound_player.stream:
			#switch_sound_player.play()

		# 可选: 如果需要，你可以链接回调函数，例如，在 tween 完成时
		current_tween.tween_callback(_on_lane_switch_animation_finished)


func _on_lane_switch_animation_finished():
	is_switching_line = false
	animatedSprite.play("default")

func on_ship_dead():
	game_over_panel.set_text("很遗憾，你因外部攻击导致飞船失控，任务暂停")
	game_over_panel.fade_in_and_pause()

func take_damage(crash_damage):
	ship_hit_sound.play()
	health_system.take_damage(crash_damage)
	UI.minus_health(crash_damage)
	camera_system.start_shake()
