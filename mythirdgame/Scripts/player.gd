extends CharacterBody2D

var gravity := ProjectSettings.get("physics/2d/default_gravity") as float
@export var move_speed: float
@export var jump_speed: float
@onready var animated: AnimatedSprite2D = $AnimatedSprite2D
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var prepare_jump_timer: Timer = $PrepareJumpTimer
var input_jump: bool = false

func _unhandled_input(event: InputEvent) -> void:
	# 提前跳跃
	if event.is_action_pressed("Jump"):
		prepare_jump_timer.start()
	# 跳跃高度
	if not event.is_action_pressed("Jump") and velocity.y < jump_speed / 2:
		velocity.y = jump_speed / 2

func _physics_process(delta: float) -> void:
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
	# 设置跳跃条件
	var judgment_jump = (is_on_floor() or coyote_timer.time_left > 0) and Input.is_action_pressed("Jump")
	# 跳跃，按空格松下后，再次按空格，才能跳跃
	if not input_jump:
		if judgment_jump or (prepare_jump_timer.time_left > 0 and is_on_floor()):
			velocity.y = jump_speed
			animated.play("Jump")
			coyote_timer.stop()
			prepare_jump_timer.stop()
	input_jump = Input.is_action_pressed("Jump")
	# 播放动画判断
	if is_on_floor():
		# 未输入和velocity.x不为零
		if not direction and not velocity.x:
			animated.play("Stand")
		else:
			animated.play("Run")
	else:
		animated.play("Jump")
	# 记录是否在地板上
	var mark_on_floor = is_on_floor()
	move_and_slide()
	# is_on_floor发生变化
	if mark_on_floor != is_on_floor():
		# 由地面变为空中，mark_on_floor为true，is_on_floor为false
		# judgment_jump为既不在地面，也没有按跳跃建，coyote_timer也未启动
		if mark_on_floor and not judgment_jump:
			coyote_timer.start()
		else:
			coyote_timer.stop()
	
	
	
