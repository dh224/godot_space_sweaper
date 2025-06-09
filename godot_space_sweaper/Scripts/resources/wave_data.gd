# WaveData.gd
class_name WaveData
extends Resource

# --- I. 波次的触发条件 ---
enum TriggerCondition {
	PREVIOUS_WAVE_ENDED,
	TIME_ELAPSED,
	MANUAL_TRIGGER,
}



@export_group("Trigger Conditions", "trigger_")
@export var trigger_condition: TriggerCondition = TriggerCondition.PREVIOUS_WAVE_ENDED
@export var trigger_time_seconds: float = 0.0


# --- II. 三条不同轨道刷怪的百分比 ---
@export_group("Track Spawn Distribution (Sum must be 1.0)", "track_spawn_")
@export_range(0.0, 1.0, 0.01)
var track1_spawn_percentage: float = 0.33

@export_range(0.0, 1.0, 0.01)
var track2_spawn_percentage: float = 0.34

@export_range(0.0, 1.0, 0.01)
var track3_spawn_percentage: float = 0.33


# --- III. 三条不同轨道的怪物池 ---
@export_group("Track Monster Pools", "track_monsters_")
@export var track1_monster_pool: Array[PackedScene] = []
@export var track2_monster_pool: Array[PackedScene] = []
@export var track3_monster_pool: Array[PackedScene] = []


# --- IV. 波次参数 ---
@export_group("Wave Configuration", "wave_config_")
@export var wave_name: String = "New Wave"
@export var total_enemies_in_wave: int = 10
@export var wave_index : int = 0
@export var spawn_interval_seconds: float = 1.0
@export var pre_wave_delay_seconds: float = 3.0

@export_group("Wave Properties (Advanced)", "wave_props_")
@export var simultaneous_spawns: int = 1

# --- V. 波次的结束条件 ---
enum EndCondition {
	ALL_ENEMIES_DEFEATED,  # 默认：所有敌人被击败
	TIME_LIMIT_EXCEEDED,   # 到达时间上限
	MANUAL_END,            # 手动结束（如剧情、按钮）
	# 可以扩展更多：例如 SPECIFIC_ENEMY_KILLED, PLAYER_REACHED_AREA 等
}

@export_group("End Conditions", "end_")
@export var end_condition: EndCondition = EndCondition.ALL_ENEMIES_DEFEATED

# 仅当 end_condition == TIME_LIMIT_EXCEEDED 时有效
@export_range(1.0, 999.0, 0.1)
var end_time_limit_seconds: float = 30.0



# --- 构造函数（仅用于代码中创建） ---
func _init(p_wave_name: String = "Default Wave", 
		   p_total_enemies: int = 10,
		   p_trigger: TriggerCondition = TriggerCondition.PREVIOUS_WAVE_ENDED,
		   p_trigger_time: float = 0.0):
	wave_name = p_wave_name
	total_enemies_in_wave = p_total_enemies
	trigger_condition = p_trigger
	trigger_time_seconds = p_trigger_time


# --- 校验函数 ---
func is_valid() -> StringName:
	var error_msg := ""

	var percentage_sum = track1_spawn_percentage + track2_spawn_percentage + track3_spawn_percentage
	if abs(percentage_sum - 1.0) > 0.001:
		error_msg += "Track spawn percentages do not sum to 1.0 (current: %.2f).\n" % percentage_sum
	
	if total_enemies_in_wave <= 0:
		error_msg += "Total enemies in wave must be greater than 0.\n"
		
	var empty_pools := []
	if track1_spawn_percentage > 0.0 and track1_monster_pool.is_empty():
		empty_pools.append("Track 1")
	if track2_spawn_percentage > 0.0 and track2_monster_pool.is_empty():
		empty_pools.append("Track 2")
	if track3_spawn_percentage > 0.0 and track3_monster_pool.is_empty():
		empty_pools.append("Track 3")
	
	if not empty_pools.is_empty():
		error_msg += "Spawn percentage > 0 but monster pool empty for: %s\n" % ", ".join(empty_pools)

	if trigger_condition == TriggerCondition.TIME_ELAPSED and trigger_time_seconds < 0:
		error_msg += "Trigger time cannot be negative for TIME_ELAPSED condition.\n"
	
	return error_msg.strip_edges()


# --- 可选：自动归一化百分比 ---
func normalize_percentages():
	var total = track1_spawn_percentage + track2_spawn_percentage + track3_spawn_percentage
	if total == 0.0:
		return
	track1_spawn_percentage /= total
	track2_spawn_percentage /= total
	track3_spawn_percentage /= total
