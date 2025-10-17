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
}

# 位于地面
const GROUND_STATES = [State.IDLE, State.RUNNING, State.LANDING]
var default_gravity := ProjectSettings.get("physics/2d/default_gravity") as float
@export var move_speed: float
@export var jump_speed: float
@onready var animated: AnimatedSprite2D = $AnimatedSprite2D
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var prepare_jump_timer: Timer = $PrepareJumpTimer
var input_jump: bool = false
# 状态变化后的第一帧
var is_first_tick: bool = false

@onready var up_left: RayCast2D = $SlidingWall/UpLeft
@onready var up_right: RayCast2D = $SlidingWall/UpRight
@onready var down_left: RayCast2D = $SlidingWall/DownLeft
@onready var down_right: RayCast2D = $SlidingWall/DownRight


func _unhandled_input(event: InputEvent) -> void:
	# 空中按下跳跃键，prepare_jump_timer计时器启动，0.2秒内落地，可直接起跳
	if event.is_action_pressed("Jump"):
		prepare_jump_timer.start()
	# 跳跃高度减半（短按跳跃键）
	if not event.is_action_pressed("Jump") and velocity.y < jump_speed / 2:
		velocity.y = jump_speed / 2

# 状态执行函数
func tick_physics(state: State, delta: float) -> void:
	match state:
		State.IDLE:
			move(default_gravity, delta)
		State.RUNNING:
			move(default_gravity, delta)
		State.JUMP:
			move(0.0 if is_first_tick else default_gravity, delta)
		State.FALL:
			move(default_gravity, delta)
		State.LANDING:
			move(default_gravity, delta)
		State.SLIDINGWALL:
			move(default_gravity / 3, delta)
	# 结束第一帧
	is_first_tick = false

func move(gravity: float, delta: float) -> void:
	# 重力下坠
	velocity.y += gravity * delta
	# 获取左右的输入
	var direction = Input.get_axis("Left", "Right")
	# 空中和陆地上的加速度
	var add_speed: float = 0.2 if is_on_floor() else 0.03
	# 左右移动，0.2秒后加速到设置速度，空中为0.03秒
	velocity.x = move_toward(velocity.x, direction * move_speed, move_speed / add_speed * delta)
	# 镜像翻转
	if direction:
		animated.flip_h = direction < 0
	move_and_slide()
	
# 状态判断函数
func get_next_state(state: State) -> State:
	# 获取左右的输入
	var direction = Input.get_axis("Left", "Right")
	# （条件1）设置跳跃条件，按下跳跃键后，并且在地板上，或者coyote_timer计时器未结束<“走”出地块后的那一帧，也可以跳跃>
	var judgment_jump1 = (is_on_floor() or coyote_timer.time_left > 0) and Input.is_action_pressed("Jump")
	# （条件2）prepare_jump_timer计时未结束和在地板上<落地提前按下跳跃键跳跃>
	var judgment_jump2 = prepare_jump_timer.time_left > 0 and is_on_floor()
	# 跳跃，按空格松下后，再次按空格，才能跳跃
	if not input_jump:
		if judgment_jump1 or judgment_jump2:
			velocity.y = jump_speed
			return State.JUMP
	input_jump = Input.is_action_pressed("Jump")
	# 判断是否站立不动
	var is_stand = not direction and not velocity.x
	match state:
		State.IDLE:
			# 不在地面时，状态变化为FALL
			if not is_on_floor():
				return State.FALL
			# 发生移动时，状态变化为RUNNING
			if not is_stand:
				return State.RUNNING
		State.RUNNING:
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
			if is_on_wall() and (Input.is_action_pressed("Left") or Input.is_action_pressed("Right")):
				return State.SLIDINGWALL
		State.LANDING:
			if not is_stand:
				return State.RUNNING
			if not animated.is_playing():
				return State.IDLE
		State.SLIDINGWALL:
			# 在地面时，状态变化为LANDING
			if is_on_floor():
				return State.LANDING
			# 不贴墙或者没有按住左右键时，状态变化为FALL
			if not is_on_wall() or not (Input.is_action_pressed("Left") or Input.is_action_pressed("Right")):
				return State.FALL
			
	return state

# 动画播放函数，只有在状态发送改变时调用
func transition_state(from: State, to: State) -> void:
	if from not in GROUND_STATES and to in GROUND_STATES:
		coyote_timer.stop()
	match to:
		State.IDLE:
			animated.play("Stand")
		State.RUNNING:
			animated.play("Run")
		State.JUMP:
			coyote_timer.stop()
			prepare_jump_timer.stop()
			animated.play("Jump")
		State.FALL:
			animated.play("Fall")
			if from in GROUND_STATES:
				# 当走出地块时，coyote_timer计时器启动0.1秒内，可进行跳跃
				coyote_timer.start()
		State.LANDING:
			animated.play("Landing")
		State.SLIDINGWALL:
			animated.play("SlidingWall")
				
	# 设置为第一帧
	is_first_tick = true
