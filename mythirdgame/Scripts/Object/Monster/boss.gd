extends Enemy

enum State {
	IDLE, WALK, ATTACK1, ATTACK2, ATTACK3, HURT, DIE
}
# 伤害对象
@onready var pending_damage: Damage
# 发现敌人
@onready var find: RayCast2D = $Graphic/Find
# 判断墙面
@onready var wall: RayCast2D = $Graphic/Wall
# 等待时间
@onready var idle_timer: Timer = $IdleTimer
# 子弹发射
@onready var bullet_timer: Timer = $BulletTimer
# 伤害范围对象
@onready var hit_box: HitBox = $Graphic/HitBox
# 血条头像
@onready var head: MarginContainer = $Control/PlayerMenuMargin/VBoxContainer/HBoxContainer/Head
# 血条进度条
@onready var health: MarginContainer = $Control/PlayerMenuMargin/VBoxContainer/HBoxContainer/StateProgressBar/Health
# 能量进度条
@onready var energy: MarginContainer = $Control/PlayerMenuMargin/VBoxContainer/HBoxContainer/StateProgressBar/Energy
# 子弹发射
@export var bullet_scene : PackedScene
# 无敌
@onready var hurt_box: HurtBox = $Graphic/HurtBox
# 狂暴阶段
@onready var attack3: bool = true
# 可以攻击
const CAN_ATTACK1 = [
	State.IDLE, State.ATTACK1, State.WALK
]
# 状态攻击
const ATTACK_STATE = [
	State.ATTACK2, State.ATTACK3
]

# 初始化
func _ready() -> void:
	# 隐藏头像，复用玩家的血量条
	head.visible = false
	energy.visible = false
	direction *= -1.0
# 判断是否发现敌人
func can_find_player() -> bool:
	# 没有发现敌人
	if not find.is_colliding():
		return false
	# 发现敌人，并且是player
	return find.get_collider() is player
# 施展伤害的对象
func _on_hurt_box_hurt(hitbox: HitBox) -> void:
	pending_damage = Damage.new()
	pending_damage.amount = hitbox.owner.stats.attack
	pending_damage.source = hitbox.owner
# 用于超过玩家后，回头
func _on_timer_timeout() -> void:
	# 未发现墙壁，转向
	if not wall.is_colliding():
		direction *= -1.0
# 无敌计时器
func _on_invincible_timer_timeout() -> void:
	# 关闭受伤检测
	hurt_box.monitoring = true
# 子弹发射计时器
func _on_bullet_timer_timeout() -> void:
	# 生成子弹节点
	var bullet_node = bullet_scene.instantiate()
	# 设置正确的子弹位置
	bullet_node.position = position + Vector2(-10, 40)
	# 将其添加进场景树
	get_tree().current_scene.add_child(bullet_node)

# 状态执行函数，调用移动函数
func tick_physics(state: State, delta: float) -> void:
	match state:
		State.WALK:
			move(max_speed / -3, delta)
		State.ATTACK2:
			move(1000.0 / -3, delta)
		State.ATTACK3:
			move(400.0 / -3, delta)

# 状态判断函数
func get_next_state(state: State) -> State:
	# 狂暴模式，进入ATTACK3态
	if stats.health <= 10 and attack3:
		return State.ATTACK3
	# 死亡判断，进入DIE状态
	if stats.health <= 0:
		return State.DIE
	# 当处于非HURT状态时，才会进入HURT状态
	if pending_damage:
		# 可以被攻击状态、不处于无敌时间，进入受伤状态
		if state in CAN_ATTACK1 and $InvincibleTimer.time_left == 0 and state not in ATTACK_STATE:
			return State.HURT
	match state:
		State.IDLE:	
			# 发现敌人，进入攻击模式
			if can_find_player():
				return State.ATTACK1
			# 等待一会后进入散步状态
			if idle_timer.is_stopped():
				return State.WALK
		State.WALK:
			# 发现敌人，进入攻击模式
			if can_find_player():
				return State.ATTACK1
			# 当前方是墙壁时，进入等待状态
			if wall.is_colliding():
				return State.IDLE
		State.ATTACK1:
			# 一段攻击计时器结束，进入二段攻击状态
			if $Attack1TimerLeft.time_left == 0:
				return State.ATTACK2
			# 没有发现敌人，进入散步状态
			if not can_find_player():
				return State.IDLE
		State.ATTACK2:
			if pending_damage:
				if $InvincibleTimer.time_left == 0:
					# 血量减少
					stats.health -= pending_damage.amount
				# 获取方向，伤害来源的位置，指向自己（史莱姆）的位置
				var dir = pending_damage.source.global_position.direction_to(global_position)
				# 改变direction的值，面对玩家，小于0朝左，大于0朝右
				if dir.x < 0:
					# 面朝左
					direction = Direction.LEFT
				else:
					# 面朝右
					direction = Direction.RIGHT
				# 清空对象
				pending_damage = null
			# 前方是墙壁，回头，direction * -1
			if wall.is_colliding():
				direction *= -1.0
			# 发现敌人，准备回头，超过敌人后两秒回头，使用工具类_on_timer_timeout()
			if can_find_player():
				$Timer.start()
			# 结束二段攻击，进入等待状态
			if $Attack2TimerLeft.time_left == 0:
				return State.IDLE
		State.ATTACK3:
			if pending_damage:
				if $InvincibleTimer.time_left == 0:
					# 血量减少
					stats.health -= pending_damage.amount
				# 获取方向，伤害来源的位置，指向自己（史莱姆）的位置
				var dir = pending_damage.source.global_position.direction_to(global_position)
				# 改变direction的值，面对玩家，小于0朝左，大于0朝右
				if dir.x < 0:
					# 面朝左
					direction = Direction.LEFT
				else:
					# 面朝右
					direction = Direction.RIGHT
				# 清空对象
				pending_damage = null
			# 前方是墙壁，回头，direction * -1
			if wall.is_colliding():
				direction *= -1.0
			# 发现敌人，准备回头，超过敌人后两秒回头，使用工具类_on_timer_timeout()
			if can_find_player():
				$Timer.start()
			# 结束三段攻击，进入等待状态
			if $Attack3TimerLeft.time_left == 0:
				return State.IDLE
		State.HURT:
			# 受击动画结束后，进入一段攻击状态
			if not animated.is_playing():
				return State.ATTACK1
	return state

# 动画播放函数，只有在状态发生改变时调用
func transition_state(_from: State, to: State) -> void:
	match to:
		State.IDLE:
			# 子弹发射计时器
			bullet_timer.stop()
			# 等待一会
			idle_timer.start()
			animated.play("Idle")
			# 前方是墙壁，回头，direction * -1
			if wall.is_colliding():
				direction *= -1.0
		State.WALK:
			animated.play("Walk")
		State.ATTACK1:
			# 子弹发射计时器
			bullet_timer.start()
			# 一段计时器
			$Attack1TimerLeft.start()
			# 开启攻击框
			hit_box.monitoring = true
			animated.play("Attack1")
		State.ATTACK2:
			# 子弹发射计时器关闭
			bullet_timer.stop()
			# 二段计时器
			$Attack2TimerLeft.start()
			animated.play("Attack2")
		State.ATTACK3:
			attack3 = false
			# 子弹发射计时器关闭
			bullet_timer.start()
			# 三段计时器
			$Attack3TimerLeft.start()
			# 开启攻击框
			hit_box.monitoring = true
			animated.play("Attack2")
		State.HURT:
			if pending_damage:
				if $InvincibleTimer.time_left == 0:
					# 血量减少
					stats.health -= pending_damage.amount
				if pending_damage and pending_damage.source and is_instance_valid(pending_damage.source):
					# 获取方向，伤害来源的位置，指向自己（史莱姆）的位置
					var dir = pending_damage.source.global_position.direction_to(global_position)
					# 改变direction的值，面对玩家，小于0朝左，大于0朝右
					if dir.x < 0:
						# 面朝左
						direction = Direction.LEFT
					else:
						# 面朝右
						direction = Direction.RIGHT
					# 清空对象
				pending_damage = null
			# 受到攻击，关闭攻击框
			hit_box.monitoring = false
			# 无敌
			hurt_box.monitoring = false
			$InvincibleTimer.start()
			animated.play("Hurt")
			SoundManager.play_sfx("SlimeHurt")
		State.DIE:
			# 死亡关闭血量条
			health.visible = false
			$AnimationPlayer.play("Die")
			$"../AnimationPlayer".play("Game_ending")
			await get_tree().create_timer(3).timeout
