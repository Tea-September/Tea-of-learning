extends Enemy

enum State {
	IDLE,
	WALK,
	RUNNING,
	HURT,
	DIE
}

@onready var pending_damage: Damage
@onready var find: RayCast2D = $Graphic/Find
@onready var if_floor: RayCast2D = $Graphic/Floor
@onready var wall: RayCast2D = $Graphic/Wall
@onready var idle_timer: Timer = $IdleTimer
@onready var hit_box: HitBox = $Graphic/HitBox
@onready var animated_boar: AnimatedSprite2D = $Graphic/AnimatedSprite2D
@onready var head: MarginContainer = $Control/PlayerMenuMargin/VSplitContainer/HBoxContainer/Head
@onready var health: MarginContainer = $Control/PlayerMenuMargin/VSplitContainer/HBoxContainer/Health

const REPEL_AMOUNT: float = 520.0

# 可以攻击
const CAN_ATTACK = [
	State.IDLE, State.RUNNING, State.WALK
]

func can_find_player() -> bool:
	if not find.is_colliding():
		return false
	return find.get_collider() is player

func _ready() -> void:
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
				# 暴走持续时间
				idle_timer.start()
				return State.RUNNING
			if idle_timer.is_stopped():
				return State.WALK
		State.WALK:
			# 发现敌人，进入暴走模式
			if can_find_player():
				# 暴走持续时间
				idle_timer.start()
				return State.RUNNING
			if not if_floor.is_colliding() or wall.is_colliding():
				return State.IDLE
		State.RUNNING:
			if not can_find_player() and idle_timer.is_stopped():
				return State.WALK
		State.HURT:
			if not animated_boar.is_playing():
				return State.RUNNING
	return state

# 动画播放函数，只有在状态发送改变时调用
func transition_state(_from: State, to: State) -> void:
	if not State.IDLE or not State.IDLE:
		idle_timer.stop()
	match to:
		State.IDLE:
			idle_timer.start()
			animated.play("Idle")
			if wall.is_colliding():
				direction *= -1.0
		State.WALK:
			animated.play("Walk")
			if not if_floor.is_colliding():
				direction *= -1.0
				if_floor.force_raycast_update()
		State.RUNNING:
			# 开启攻击框
			hit_box.monitoring = true
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
			health.visible = false
			$AnimationPlayer.play("Die")
# 血量计算
func _on_hurt_box_hurt(hitbox: HitBox) -> void:
	pending_damage = Damage.new()
	pending_damage.amount = hitbox.owner.stats.attack
	pending_damage.source = hitbox.owner
