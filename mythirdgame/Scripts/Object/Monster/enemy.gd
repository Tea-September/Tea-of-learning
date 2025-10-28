class_name Enemy
extends CharacterBody2D

enum Direction {
	LEFT = -1,
	RIGHT = 1,
}

@export var direction = Direction.LEFT:
	set(T):
		direction = T
		# 等待redy信号
		if not is_node_ready():
			await ready
		graphic.scale.x = -direction
@export var max_speed: float = 180
@export var acceleration: float = 2000

@onready var graphic: Node2D = $Graphic
@onready var animated: AnimatedSprite2D = $Graphic/AnimatedSprite2D

var default_gravity = ProjectSettings.get("physics/2d/default_gravity") as float

func move(speed: float, delta: float) -> void:
	# 左右移动
	velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
	# 重力下坠
	velocity.y += default_gravity * delta
	move_and_slide()
