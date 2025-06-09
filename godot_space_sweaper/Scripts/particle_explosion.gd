extends Node2D
@onready var particles: GPUParticles2D = $GPUParticles2D # 确保节点路径正确
# @onready var sound_player: AudioStreamPlayer = $AudioStreamPlayer # 如果需要访问

# 我们可以将屏幕抖动逻辑也放在这里，或者通过信号通知一个全局管理器
# 为了简单，我们直接在这里触发
# 如果你有一个全局的相机管理器，最好通过它来处理抖动
var screen_shake_intensity: float = 10.0 # 抖动强度
var screen_shake_duration: float = 0.1  # 抖动持续时间

func _ready():
	# 确保粒子开始发射
	particles.emitting = true

	# 触发屏幕抖动
	# 方式一: 直接控制默认相机 (如果只有一个主相机且容易访问)
	var main_camera = get_viewport().get_camera_2d()
	if main_camera and main_camera.has_method("shake"): # 假设相机有shake方法
		main_camera.shake(screen_shake_intensity, screen_shake_duration)
	# 方式二: 发射信号，让相机或其他管理器响应
	# EventBus.emit_signal("screen_shake_requested", screen_shake_intensity, screen_shake_duration)
	# (你需要先设置好 EventBus 自动加载)

	# 销毁自身
	# 由于 GPUParticles2D 没有 "所有粒子发射完毕且消失" 的信号，
	# 我们必须使用 Timer，并根据粒子的 Lifetime 和其他参数估算总时长。
	# 一个安全的估算是 GPUParticles2D 的 Lifetime 属性，
	# 加上一点点缓冲时间，或者如果粒子有很长的淡出时间。
	var explosion_total_duration = particles.lifetime + 0.05 # 例如，粒子生命周期再加一点缓冲
	
	var timer = Timer.new()
	timer.wait_time = explosion_total_duration
	timer.one_shot = true
	timer.timeout.connect(queue_free) # 连接 timeout 信号到 queue_free
	add_child(timer) # 将Timer添加到场景树，否则它不会运行
	timer.start()
