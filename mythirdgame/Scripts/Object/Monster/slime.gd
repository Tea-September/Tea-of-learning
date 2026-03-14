extends Enemy

enum State {
	IDLE,
	WALK,
	ATTACK,
	HURT,
	DIE
}

# 伤害对象
@onready var pending_damage: Damage
# 发现敌人
@onready var find: RayCast2D = $Graphic/Find
# 判断陆地
@onready var if_floor: RayCast2D = $Graphic/Floor
# 判断墙面
@onready var wall: RayCast2D = $Graphic/Wall
# 等待时间
@onready var idle_timer: Timer = $IdleTimer
# 子弹发射
@onready var bullet_timer: Timer = $BulletTimer
# 伤害范围对象
@onready var hit_box: HitBox = $Graphic/HitBox
# 史莱姆动画
@onready var animated_slime: AnimatedSprite2D = $Graphic/AnimatedSprite2D
# 血条头像
@onready var head: MarginContainer = $Control/PlayerMenuMargin/VBoxContainer/HBoxContainer/Head
# 血条进度条
@onready var health: MarginContainer = $Control/PlayerMenuMargin/VBoxContainer/HBoxContainer/StateProgressBar/Health
# 能量进度条
@onready var energy: MarginContainer = $Control/PlayerMenuMargin/VBoxContainer/HBoxContainer/StateProgressBar/Energy
# 
@export var bullet_scene : PackedScene

# 击飞距离
const REPEL_AMOUNT: float = 520.0

# 可以攻击
const CAN_ATTACK = [
	State.IDLE, State.ATTACK, State.WALK
]

# 判断是否发现敌人
func can_find_player() -> bool:
	# 没有发现敌人
	if not find.is_colliding():
		return false
	# 发现敌人，并且是player
	return find.get_collider() is player

# 初始化
func _ready() -> void:
	# 隐藏头像
	head.visible = false
	energy.visible = false

# 状态执行函数
func tick_physics(state: State, delta: float) -> void:
	match state:
		State.IDLE:
			move(0.0, delta)
		State.WALK:
			move(max_speed / 3, delta)
		State.ATTACK:
			move(0.0, delta)
		State.HURT:
			move(0.0, delta)
		State.DIE:
			move(0.0, delta)

# 状态判断函数
func get_next_state(state: State) -> State:
	# 死亡判断
	if stats.health <= 0:
		return State.DIE
	# 当处于非HURT状态时，才会进入HURT状态
	if pending_damage:
		if state in CAN_ATTACK:
			return State.HURT
	match state:
		State.IDLE:	
			# 发现敌人，进入攻击模式
			if can_find_player():
				return State.ATTACK
			# 等待一会后进入散步
			if idle_timer.is_stopped():
				return State.WALK
		State.WALK:
			# 发现敌人，进入攻击模式
			if can_find_player():
				return State.ATTACK
			# 当前方是断崖或者墙壁时，进入等待状态
			if not if_floor.is_colliding() or wall.is_colliding():
				return State.IDLE
		State.ATTACK:
			# 没有发现敌人，进入散步状态
			if not can_find_player():
				return State.IDLE
		State.HURT:
			# 受击动画结束后，进入攻击状态
			if not animated_slime.is_playing():
				return State.ATTACK
	return state

# 动画播放函数，只有在状态发送改变时调用
func transition_state(_from: State, to: State) -> void:
	match to:
		State.IDLE:
			# 子弹发射计时器
			bullet_timer.stop()
			# 等待一会
			idle_timer.start()
			animated.play("Idle")
			# 前方是墙壁，回头
			if wall.is_colliding():
				direction *= -1.0
		State.WALK:
			animated.play("Walk")
			# 前方是断崖，回头
			if not if_floor.is_colliding():
				direction *= -1.0
				# 更新if_floor，判断前方是否有地面
				if_floor.force_raycast_update()
		State.ATTACK:
			# 子弹发射计时器
			bullet_timer.start()
			# 开启攻击框
			hit_box.monitoring = true
			animated.play("Attack")
		State.HURT:
			# 血量减少
			stats.health -= pending_damage.amount
			# 获取方向，伤害来源的位置，指向自己（史莱姆）的位置
			var dir = pending_damage.source.global_position.direction_to(global_position)
			# 面对玩家
			if dir.x > 0:
				# 面朝左
				direction = Direction.LEFT
			else:
				# 面朝右
				direction = Direction.RIGHT
			# 击退史莱姆
			velocity = dir * REPEL_AMOUNT
			# 清空对象
			pending_damage = null
			# 受到攻击，关闭攻击框
			hit_box.monitoring = false
			animated.play("Hurt")
		State.DIE:
			# 死亡关闭血量条
			health.visible = false
			$AnimationPlayer.play("Die")

# 施展伤害的对象
func _on_hurt_box_hurt(hitbox: HitBox) -> void:
	pending_damage = Damage.new()
	pending_damage.amount = hitbox.owner.stats.attack
	pending_damage.source = hitbox.owner

# 子弹发射
func _on_timer_timeout() -> void:
	# 生成子弹节点
	var bullet_node = bullet_scene.instantiate()
	# 设置正确的子弹位置
	bullet_node.position = position + Vector2(6, 6)
	# 将其添加进场景树
	get_tree().current_scene.add_child(bullet_node)
