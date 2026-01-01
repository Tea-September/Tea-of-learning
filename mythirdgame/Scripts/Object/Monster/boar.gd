extends Enemy

enum State {
	IDLE,
	WALK,
	RUNNING,
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
# 伤害范围对象
@onready var hit_box: HitBox = $Graphic/HitBox
# 野猪动画
@onready var animated_boar: AnimatedSprite2D = $Graphic/AnimatedSprite2D
# 血条头像
@onready var head: MarginContainer = $Control/PlayerMenuMargin/VSplitContainer/HBoxContainer/Head
# 血条进度条
@onready var health: MarginContainer = $Control/PlayerMenuMargin/VSplitContainer/HBoxContainer/Health

# 击飞距离
const REPEL_AMOUNT: float = 520.0

# 可以攻击
const CAN_ATTACK = [
	State.IDLE, State.RUNNING, State.WALK
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

# 状态执行函数
func tick_physics(state: State, delta: float) -> void:
	match state:
		State.IDLE:
			move(0.0, delta)
		State.WALK:
			move(max_speed / 3, delta)
		State.RUNNING:
			if not if_floor.is_colliding() or wall.is_colliding():
				direction *= -1.0
			move(max_speed, delta)
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
			# 发现敌人，进入暴走模式
			if can_find_player():
				return State.RUNNING
			# 等待一会后进入散步
			if idle_timer.is_stopped():
				return State.WALK
		State.WALK:
			# 发现敌人，进入暴走模式
			if can_find_player():
				return State.RUNNING
			# 当前方是断崖或者墙壁时，进入等待状态
			if not if_floor.is_colliding() or wall.is_colliding():
				return State.IDLE
		State.RUNNING:
			# 没有发现敌人，并且追击计时器也停止了，进入散步状态
			if not can_find_player() and idle_timer.is_stopped():
				return State.WALK
		State.HURT:
			# 受击动画结束后，进入暴走状态
			if not animated_boar.is_playing():
				return State.RUNNING
	return state

# 动画播放函数，只有在状态发送改变时调用
func transition_state(_from: State, to: State) -> void:
	match to:
		State.IDLE:
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
		State.RUNNING:
			# 开启攻击框
			hit_box.monitoring = true
			# 暴走计时器
			idle_timer.start()
			animated.play("Run")
		State.HURT:
			# 血量减少
			stats.health -= pending_damage.amount
			# 获取方向，伤害来源的位置，指向自己（野猪）的位置
			var dir = pending_damage.source.global_position.direction_to(global_position)
			# 面对玩家
			if dir.x > 0:
				# 面朝左
				direction = Direction.LEFT
			else:
				# 面朝右
				direction = Direction.RIGHT
			# 击退野猪
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
