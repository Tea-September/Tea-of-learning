extends CharacterBody2D

var gravity := ProjectSettings.get("physics/2d/default_gravity") as float
@export var move_speed: float
@export var jump_speed: float
@onready var animated: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	# 重力下坠
	velocity.y += gravity * delta
	# 获取左右的输入
	var direction = Input.get_axis("Left", "Right")
	# 左右移动
	velocity.x = direction * move_speed
	# 镜像翻转
	if direction:
		animated.flip_h = direction < 0
	# 跳跃
	if is_on_floor() and Input.is_action_pressed("Jump"):
		velocity.y = jump_speed
		animated.play("Jump")
	# 播放动画判断
	if is_on_floor():
		if direction:
			animated.play("Run")
		else:
			animated.play("Stand")
	else:
		animated.play("Jump")
	move_and_slide()
