extends BaseBullet
const BIG_EXPLOSION_SCENE = preload("res://Scenes/big_particle_explosion.tscn") 

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Target"):
		if area.has_method("take_damage"):
			var explosion_instance = BIG_EXPLOSION_SCENE.instantiate()
			# 获取当前场景树根节点（最安全的父节点添加方式）
			var root_node = get_tree().root
			UI.rocket_hit_sound.play()
			# 在击中位置附近生成随偏移量
			var random_offset = Vector2(
				randf_range(0, 45),  # X轴随机偏移 -20到20像素
				randf_range(-25, 25)   # Y轴随机偏移 -20到20像素
			)
			
			root_node.add_child(explosion_instance)
			# 设置粒子效果位置为击中位置+随机偏移
			explosion_instance.global_position = global_position + random_offset
			area.take_damage(damage, GlobalEnums.BulletType.NORMAL)
			queue_free()
