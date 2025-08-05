extends Area2D

# 子弹速度
@export var bullet_speed : float = 100

func _ready() -> void:
	# 等待3秒，timeout为倒计时结束才能执行后面的代码
	await get_tree().create_timer(3).timeout
	# 销毁节点
	queue_free()

func _physics_process(delta: float) -> void:
	# 通过更改全局坐标，来实现子弹的移动
	position += Vector2(bullet_speed, 0) * delta

# area进入
func _on_area_entered(area: Area2D) -> void:
	# 判断进入的area是否包含在Slime分组下
	if area.is_in_group("Slime"):
		# 史莱姆死亡函数
		area.slm_over()
		# 销毁当前节点
		queue_free()
