extends Node2D
class_name WaveManager

signal wave_started(wave_index: int)
signal wave_ended(wave_index: int)
signal enemy_spawned(enemy: Node2D)

@export var waves: Array[WaveData] = []

@export_group("生成点")
@export var track1_spawn_point: NodePath
@export var track2_spawn_point: NodePath
@export var track3_spawn_point: NodePath

var _current_wave_index := -1
var _active_enemies := []
var _spawn_timer := 0.0
var _wave_timer := 0.0
var _enemies_spawned := 0
var _ready_to_spawn := false
var _manual_trigger := false

var _wave_ended_waiting_next := false

func _process(delta: float) -> void:
	if _current_wave_index >= waves.size():
		return

	if  _ready_to_spawn == false:
		_check_start_next_wave(delta)
		return

	var wave = waves[_current_wave_index]

	if _ready_to_spawn:
		_spawn_timer -= delta
		_wave_timer += delta
		if _spawn_timer <= 0.0 and _enemies_spawned < wave.total_enemies_in_wave:
			_spawn_enemies(wave)
			_spawn_timer = wave.spawn_interval_seconds

		_check_wave_end(wave)

func _check_start_next_wave(delta: float) -> void:
	
	var next_wave_index = _current_wave_index + 1
	if next_wave_index >= waves.size():
		return

	var wave = waves[next_wave_index]

	match wave.trigger_condition:
		WaveData.TriggerCondition.PREVIOUS_WAVE_ENDED:
			if _current_wave_index == -1 or _active_enemies.is_empty():
				_start_wave(next_wave_index)
		WaveData.TriggerCondition.TIME_ELAPSED:
			wave.trigger_time_seconds -= delta
			if wave.trigger_time_seconds <= 0.0:
				_start_wave(next_wave_index)
		WaveData.TriggerCondition.MANUAL_TRIGGER:
			if _manual_trigger:
				_manual_trigger = false
				_start_wave(next_wave_index)

func trigger_manual_wave():
	_manual_trigger = true

func _start_wave(index: int):
	_current_wave_index = index
	var wave = waves[index]
	_spawn_timer = wave.pre_wave_delay_seconds
	_wave_timer = 0.0
	_enemies_spawned = 0
	_ready_to_spawn = true
	emit_signal("wave_started", index)
	print("Wave %d started: %s" % [index, wave.wave_name])

func _spawn_enemies(wave: WaveData):
	var to_spawn = min(wave.simultaneous_spawns, wave.total_enemies_in_wave - _enemies_spawned)
	for i in to_spawn:
		var enemy_track = _choose_enemy_track(wave)
		var enemy_scene = _choose_enemy_with_track(wave, enemy_track)
		if enemy_scene:
			var enemy = enemy_scene.instantiate()
			var spawn_point = _choose_spawn_point_with_track(enemy_track)
			if spawn_point:
				spawn_point.add_child(enemy)
				_active_enemies.append(enemy)
				emit_signal("enemy_spawned", enemy)
				enemy.connect("died", Callable(self, "_on_enemy_died").bind(enemy))
		_enemies_spawned += 1

func _choose_enemy_scene(wave: WaveData) -> PackedScene:
	var r = randf()
	if r < wave.track1_spawn_percentage: # 0.2
		return wave.track1_monster_pool.pick_random()
	elif r < wave.track1_spawn_percentage + wave.track2_spawn_percentage: # 0.2~0.6
		return wave.track2_monster_pool.pick_random()
	else:
		return wave.track3_monster_pool.pick_random()

func _choose_enemy_track(wave : WaveData) -> int:
	var r = randf()
	if r < wave.track1_spawn_percentage: # 0.2     
		return 0
	elif r < wave.track1_spawn_percentage + wave.track2_spawn_percentage: # 0.2~0.6
		return 1
	else:
		return 2


func _choose_enemy_with_track(wave: WaveData, track : int) -> PackedScene:
	if track == 0:
		return wave.track1_monster_pool.pick_random()
	elif track == 1:
		return wave.track2_monster_pool.pick_random()
	elif track == 2:
		return wave.track3_monster_pool.pick_random()
	return wave.track3_monster_pool.pick_random()


func _choose_spawn_point(wave: WaveData) -> Node:
	var r = randf()
	if r < wave.track1_spawn_percentage:
		return get_node(track1_spawn_point)
	elif r < wave.track1_spawn_percentage + wave.track2_spawn_percentage:
		return get_node(track2_spawn_point)
	else:
		return get_node(track3_spawn_point)
func _choose_spawn_point_with_track(track : int) -> Node:
	if track == 0:
		return get_node(track1_spawn_point)
	elif track == 1:
		return get_node(track2_spawn_point)
	elif track == 2:
		return get_node(track3_spawn_point)
	return get_node(track3_spawn_point)

func _on_enemy_died(enemy_name: String, was_killed: bool, enemy_ref):
	_active_enemies.erase(enemy_ref)
	if  was_killed:
		UI.killed_update_text(enemy_name)

func _check_wave_end(wave: WaveData):
	match wave.end_condition:
		WaveData.EndCondition.ALL_ENEMIES_DEFEATED:
			if _enemies_spawned >= wave.total_enemies_in_wave and _active_enemies.is_empty():
				_end_wave()
		WaveData.EndCondition.TIME_LIMIT_EXCEEDED:
			if _wave_timer >= wave.end_time_limit_seconds:
				_end_wave()
		WaveData.EndCondition.MANUAL_END:
			# 等待外部调用 end_current_wave()
			pass

func end_current_wave():
	_end_wave()

func _end_wave():
	_ready_to_spawn = false
	emit_signal("wave_ended", _current_wave_index)
	print("Wave %d ended." % _current_wave_index)
	_wave_ended_waiting_next = true

func restart_game():
	get_tree().reload_current_scene()
