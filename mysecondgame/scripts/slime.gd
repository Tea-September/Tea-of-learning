extends Node2D

# 速度
@export var Speed : float;
# 检测左右碰撞
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastleft
# 动画
@onready var animated: AnimatedSprite2D = $AnimatedSprite2D
# 方向
var direction = 1

func _physics_process( delta: float ) -> void:
	# 检测右边是否发送碰撞
	var collider_right = ray_cast_right.get_collider()
	# 检测左边是否发送碰撞
	var collider_left = ray_cast_left.get_collider()
	# 判断右边是否碰撞，如果是玩家，则不改变方向
	if collider_right and not collider_right.is_in_group("player"):
		# 改为向左移动
		direction = -1
		# 改变动画水平播放
		animated.flip_h = true
	# 判断左边是否碰撞，如果是玩家，则不改变方向
	elif collider_left and not collider_left.is_in_group("player"):
		# 改为向右移动
		direction = 1
		# 改变动画水平播放
		animated.flip_h = false
	# 史莱姆移动
	position.x += Speed * delta * direction
