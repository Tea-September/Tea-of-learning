extends CharacterBody2D

# 玩家移动速度
@export var move_speed : float = 50
# 创建AnimatedSprite2D类型的变量，作用是访问动画
@export var animator : AnimatedSprite2D
# bool 变量：true或者false
@export var is_game_over : bool = true
# 保存场景中的节点到bullet_scene，需要设置保存那个场景
@export var bullet_scene : PackedScene
# 子弹冷却时间
var bullet_cooling_time : float = 0.0
# 滚动冷却时间
var scroll_cooling_time : float = 0.0
# 技能是否准备好
var colling_over : bool = true

func _process(delta: float) -> void:
	# 消除警告
	delta = delta
	# 跑动音效判断
	if velocity == Vector2.ZERO or is_game_over != true:
		$RunningSound.stop()
	# 判断音频是否播放
	elif not $RunningSound.playing:
		$RunningSound.play()

func _physics_process(delta: float) -> void:
	# 玩家移动
	velocity = Input.get_vector("left", "right", "up", "down") * move_speed
	# 如果游戏没有结束，则基于玩家输入移动角色
	if is_game_over:
		# 如果速度为0，播放待机动画
		if velocity == Vector2.ZERO:
			animator.play("idle")
		# 翻滚一段距离
		elif Input.is_action_pressed("space") and scroll_cooling_time <= 5.0:
			if  scroll_cooling_time >= 2.0:
				velocity = Input.get_vector("left", "right", "up", "down") * move_speed
				if velocity == Vector2.ZERO:
					animator.play("idle")
				else:
					animator.play("run")
			else:
				colling_over = false
				velocity = Input.get_vector("left", "right", "up", "down") * move_speed * 2
				animator.play("rolling")
		else:
			animator.play("run")
		if not colling_over:
			scroll_cooling_time += delta
		if scroll_cooling_time > 5.0:
			scroll_cooling_time = 0.0
			colling_over = true
		# 发射子弹
		if Input.is_action_pressed("fire") and not Input.is_action_pressed("space"):
			if Time.get_ticks_msec() / 1000.0 - bullet_cooling_time >= 1.0:
				# 距离上次调用超过1秒，执行函数
				_on_fire()
				bullet_cooling_time = Time.get_ticks_msec() / 1000.0  # 更新时间
		move_and_slide()
		  

# 游戏结束函数
func game_over():
	# 判断游戏是否结束
	if is_game_over:
		# 修改玩家状态
		is_game_over = false
		# 设置游戏结束，播放失败动画
		animator.play("game_over")
		# 显示游戏结束
		get_tree().current_scene.show_game_over()
		# 游戏结束音频
		$GameOverSound.play()
		# 重新加载场景
		$RestarTimer.start()

# 发射子弹的函数
func _on_fire() -> void:
	# 如果玩家在移动，或者游戏结束了，则不生成子弹
	#if velocity != Vector2.ZERO or is_game_over != true:
	#	return
	# 播放开火音效
	$FireSound.play()
	# 生成子弹节点
	var bullet_node = bullet_scene.instantiate()
	# 设置正确的子弹位置
	bullet_node.position = position + Vector2(6, 6)
	# 将其添加进场景树
	get_tree().current_scene.add_child(bullet_node)

func _reload_scene() -> void:
	get_tree().reload_current_scene()
