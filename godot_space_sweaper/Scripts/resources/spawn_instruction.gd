# spawn_instruction.gd
extends Resource
class_name SpawnInstruction

@export var enemy_type: EnemyType # 要生成的敌人类型
@export var count: int = 1 # 生成数量
# 指定轨道索引：0=高轨道, 1=中轨道, 2=低轨道, -1=随机轨道
@export_range(-1, 2, 1) var lane_index: int = -1
@export var delay_before_this_group: float = 0.0 # 生成这组敌人之前的延迟（秒）
@export var spawn_interval: float = 0.5 # 在这组中，生成每个敌人之间的时间间隔（秒）
