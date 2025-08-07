extends CharacterBody2D

# 速度
const SPEED = 130.0
# 跳跃速度
const JUMP_VELOCITY = -300.0
# 分数
@export var Score : int;
# 动画
@onready var animated: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# 获取左右的输入
	var direction := Input.get_axis("Left", "Right")
	# 镜像翻转
	if direction > 0:
		animated.flip_h = false
	elif  direction < 0:
		animated.flip_h = true
	# 不在空中播放动画
	if is_on_floor():
		if direction == 0:
			animated.play("idle")
		else:
			animated.play("run")
	else:
		animated.play("jump")
		
	# 添加重力
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# 跳跃，在地板上时
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	velocity.x = direction * SPEED
	
	move_and_slide()
