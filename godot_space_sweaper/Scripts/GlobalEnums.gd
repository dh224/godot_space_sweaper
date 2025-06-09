extends Node

enum TargetType {
	SKY_JUNK,       # 普通太空垃圾
	RECYCLABLE,     # 可回收物 (如果它是一种特殊垃圾)
	ENEMY_SHIP,     # 敌方飞船
	# 可以添加更多，如 ASTEROID, BOSS 等
}
enum BulletType{
	NORMAL,
	RECYCLE,
	ROCKET
}
