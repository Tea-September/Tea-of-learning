extends Area2D

# 史莱姆速度
@export var slime_speed : float = -100
# 史莱姆是否存活
@export var is_slm_over : bool = true

func _physics_process(delta: float) -> void:
	# 判断史莱姆是否存活
	if is_slm_over:
		# 通过更改全局坐标，来实现史莱姆的移动
		position += Vector2(slime_speed, 0) * delta
	# 史莱姆x轴坐标小于-240时，销毁史莱姆节点
	if position.x < -240:
		queue_free()

# body进入
func _on_body_entered(body: Node2D) -> void:
	# 如果玩家物体进入了史莱姆的区域，则让玩家输掉游戏
	if body is CharacterBody2D:
		body.game_over()

# 史莱姆死亡函数
func slm_over():
	# 计数器，当消灭史莱姆时，分数加一
	# 访问方式：通过访问根节点，来访问根节点的变量
	get_tree().current_scene.score += 1
	# 修改史莱姆是否存活
	is_slm_over = false
	# 播放史莱姆死亡音频
	$DeathSound.play()
	# 播放史莱姆死亡动画
	$AnimatedSprite2D.play("death")
	# 删除史莱姆碰撞体积
	$CollisionShape2D.queue_free()
	# 等待三秒，timeout为倒计时结束才能执行后面的代码
	await get_tree().create_timer(0.6).timeout
	# 销毁节点
	queue_free()
