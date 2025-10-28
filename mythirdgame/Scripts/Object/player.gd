class_name player
extends CharacterBody2D

# 玩家状态
enum State{
	# 待机
	IDLE,
	# 跑动
	RUNNING,
	# 跳跃
	JUMP,
	# 下落
	FALL,
	# 着陆
	LANDING,
	# 滑墙
	SLIDINGWALL,
	# 蹬墙跳
	WALLJUMP,
	# 一段攻击
	ATTACK_1,
	# 二段攻击
	ATTACK_2,
	# 三段攻击
	ATTACK_3,
}

# 位于地面
const GROUND_STATES = [
	State.IDLE, State.RUNNING, State.LANDING, 
	State.ATTACK_1, State.ATTACK_2, State.ATTACK_3
]
const WALL_JUMP_VELOCITY = Vector2(600, -400)
# 移动速度
@export var move_speed: float
# 跳跃高度
@export var jump_speed: float
# 是否能够连击
@export var can_combo: bool = false
# 人物动画
@onready var animated: AnimatedSprite2D = $Graphics/AnimatedSprite2D
# 场景翻转
@onready var graphics: Node2D = $Graphics
# 离地延迟跳跃
@onready var coyote_timer: Timer = $CoyoteTimer
# 空中预备跳跃
@onready var prepare_jump_timer: Timer = $PrepareJumpTimer
# 贴墙检测射线
@onready var up_sliding_wall: RayCast2D = $Graphics/SlidingWall/UpSlidingWall
@onready var down_sliding_wall: RayCast2D = $Graphics/SlidingWall/DownSlidingWall

# 重力
var default_gravity = ProjectSettings.get("physics/2d/default_gravity") as float
# 按下跳跃键会变成true，防止未松开跳跃键导致的连续跳跃
var input_jump: bool = false
# 状态变化后的第一帧
var is_first_tick: bool = false
# 判断是否按下左键
var is_left_wall: bool = false
# 判断可以连击事件是否出现
var is_combo_requested: bool = false

func _unhandled_input(event: InputEvent) -> void:
	# 空中按下跳跃键，prepare_jump_timer计时器启动，0.2秒内落地，可直接起跳
	if event.is_action_pressed("Jump"):
		prepare_jump_timer.start()
	# 跳跃高度减半（短按跳跃键）
	if not event.is_action_pressed("Jump") and velocity.y < jump_speed / 2:
		velocity.y = jump_speed / 2
	# 按下攻击键，并且可以连击
	if event.is_action_pressed("Attack") and can_combo:
		is_combo_requested = true

# 状态执行函数
func tick_physics(state: State, delta: float) -> void:
	match state:
		State.IDLE:
			move(default_gravity, delta)
		State.RUNNING:
			move(default_gravity, delta)
		State.JUMP:
			# 跳跃第一帧无重力
			move(0.0 if is_first_tick else default_gravity, delta)
		State.FALL:
			move(default_gravity, delta)
		State.LANDING:
			move(default_gravity, delta)
		State.SLIDINGWALL:
			# 滑墙时，下坠速度除三
			move(default_gravity / 5, delta)
		State.WALLJUMP:
			# 跳跃第一帧无重力
			move(0.0 if is_first_tick else default_gravity, delta)
		#State.ATTACK_1:
			#move(default_gravity, delta)
		#State.ATTACK_2:
			#move(default_gravity, delta)
		#State.ATTACK_3:
			#move(default_gravity, delta)
	# 结束第一帧
	is_first_tick = false

func move(gravity: float, delta: float) -> void:
	# 重力下坠
	velocity.y += gravity * delta
	# 获取左右的输入
	var direction = Input.get_axis("Left", "Right")
	# 空中和陆地上的加速度
	var add_speed: float = 0.2 if is_on_floor() else 0.1
	# 左右移动，0.2秒后加速到设置速度，空中为0.1秒
	velocity.x = move_toward(velocity.x, direction * move_speed, move_speed / add_speed * delta)
	# 镜像翻转
	if direction:
		graphics.scale.x = -1.0 if direction < 0 else 1.0
	move_and_slide()

# 状态判断函数
func get_next_state(state: State) -> State:
	# 获取左右的输入
	var direction = Input.get_axis("Left", "Right")
	# （条件1）设置跳跃条件，按下跳跃键后，并且在地板上，或者coyote_timer计时器未结束<“走”出地块后的那一帧，也可以跳跃>
	var judgment_jump1 = (is_on_floor() or coyote_timer.time_left > 0) and Input.is_action_pressed("Jump")
	# （条件2）prepare_jump_timer计时未结束和在地板上<落地提前按下跳跃键跳跃>
	var judgment_jump2 = prepare_jump_timer.time_left > 0 and is_on_floor()
	# 滑墙限制1，需要顶部和底部都贴近墙面
	var is_sliding1 = up_sliding_wall.is_colliding() and down_sliding_wall.is_colliding()
	# 滑墙限制2，需要按住左或右方向键
	var is_sliding2 = Input.is_action_pressed("Left") or Input.is_action_pressed("Right")
	# 跳跃，按空格松下后，再次按空格，才能跳跃
	if not input_jump:
		if judgment_jump1 or judgment_jump2:
			return State.JUMP
	input_jump = Input.is_action_pressed("Jump")
	# 判断是否站立不动
	var is_stand = not direction and not velocity.x
	# 在地面时,并且没有地板，状态变化为FALL
	if state in GROUND_STATES and not is_on_floor():
		return State.FALL
	match state:
		State.IDLE:
			# 玩家按下攻击键位，状态变化为ATTACK_1
			if Input.is_action_just_pressed("Attack"):
				return State.ATTACK_1
			# 发生移动时，状态变化为RUNNING
			if not is_stand:
				return State.RUNNING
		State.RUNNING:
			# 玩家按下攻击键位，状态变化为ATTACK_1
			if Input.is_action_just_pressed("Attack"):
				return State.ATTACK_1
			# 未发生移动时，状态变化为IDLE
			if is_stand:
				return State.IDLE
		State.JUMP:
			# 下坠时，状态变化为FALL
			if velocity.y >= 0:
				return State.FALL
		State.FALL:
			# 在地面时，状态变化为LANDING
			if is_on_floor():
				return State.LANDING
			# 贴墙坠，状态变化为SLIDINGWALL
			if is_on_wall() and is_sliding1 and is_sliding2:
				return State.SLIDINGWALL
		State.LANDING:
			# 移动状态，状态变化为RUNNING
			if not is_stand:
				return State.RUNNING
			# 着陆动画播放完毕，状态变化为IDLE
			if not animated.is_playing():
				return State.IDLE
		State.SLIDINGWALL:
			# 蹬墙跳，并且不是第一帧
			if prepare_jump_timer.time_left > 0 and not is_first_tick:
				if is_left_wall:
					if Input.is_action_pressed("Right"):
						return State.WALLJUMP
				else:
					if Input.is_action_pressed("Left"):
						return State.WALLJUMP
			# 在地面时，状态变化为LANDING
			if is_on_floor():
				return State.LANDING
			# 不贴墙或者没有按住左右键时，状态变化为FALL
			if not is_on_wall() or not (Input.is_action_pressed("Left") or Input.is_action_pressed("Right")):
				return State.FALL
		State.WALLJUMP:
			# 贴墙坠，状态变化为SLIDINGWALL，并且不是第一帧
			if is_on_wall() and is_sliding1 and is_sliding2 and not is_first_tick:
				return State.SLIDINGWALL
			# 下坠时，状态变化为FALL
			if velocity.y >= 0:
				return State.FALL
		State.ATTACK_1:
			if not animated.is_playing():
				if is_combo_requested:
					return State.ATTACK_2
				else:
					return State.IDLE
		State.ATTACK_2:
			if not animated.is_playing():
				if is_combo_requested:
					return State.ATTACK_3
				else:
					return State.IDLE
		State.ATTACK_3:
			if not animated.is_playing():
				return State.IDLE
	return state

# 动画播放函数，只有在状态发送改变时调用
func transition_state(from: State, to: State) -> void:
	# 当状态变化前不位于地面、变化后位于地面时coyote_timer停止
	if from not in GROUND_STATES and to in GROUND_STATES:
		coyote_timer.stop()
	# 重置is_combo_requested
	is_combo_requested = false
	match to:
		State.IDLE:
			animated.play("Stand")
		State.RUNNING:
			animated.play("Run")
		State.JUMP:
			coyote_timer.stop()
			prepare_jump_timer.stop() 
			velocity.y = jump_speed
			animated.play("Jump")
		State.FALL:
			animated.play("Fall")
			if from in GROUND_STATES:
				# 当走出地块时，coyote_timer计时器启动0.1秒内，可进行跳跃
				coyote_timer.start()
		State.LANDING:
			animated.play("Landing")
		State.SLIDINGWALL:
			is_left_wall = Input.is_action_pressed("Left")
			animated.play("SlidingWall")
		State.WALLJUMP:
			prepare_jump_timer.stop()
			velocity = WALL_JUMP_VELOCITY
			velocity.x *= get_wall_normal().x
			animated.play("Jump")
		State.ATTACK_1:
			animated.play("Attack1")
		State.ATTACK_2:
			animated.play("Attack2")
		State.ATTACK_3:
			animated.play("Attack3")
	# 引擎速度减慢
	if to == State.WALLJUMP:
		Engine.time_scale = 0.5
	if from == State.WALLJUMP:
		Engine.time_scale = 1.0
	# 设置为第一帧
	is_first_tick = true
