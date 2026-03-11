# 类名
class_name PlayerMove
extends Node

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
	# 受伤
	HURT,
	# 死亡
	DIE,
	# 开始滑铲
	SLIDESTART,
	# 滑铲
	SLIDETACKLE,
	# 站起
	UPSTANDING
}

func _move(Player: CharacterBody2D, gravity: float, delta: float) -> void:
	# 重力下坠
	Player.velocity.y += gravity * delta
	# 游戏结束时，无法移动
	if Player.game_over:
		# 获取左右的输入
		var movement = Input.get_axis("Left", "Right")
		# 空中和陆地上的加速度
		var add_speed: float = 0.2 if Player.is_on_floor() else 0.1
		# 左右移动，0.2秒后加速到设置速度，空中为0.1秒
		Player.velocity.x = move_toward(Player.velocity.x, movement * Player.move_speed, Player.move_speed / add_speed * delta)
		# 镜像翻转
		if movement:
			Player.direction = Player.Direction.LEFT if movement < 0 else Player.Direction.RIGHT
	Player.move_and_slide()
	
func _slide(Player: CharacterBody2D, gravity: float, delta: float) -> void:
	# 重力下坠
	Player.velocity.y += gravity * delta
	# 游戏结束时，无法移动
	if Player.game_over:
		# 左右滑铲
		Player.velocity.x = Player.direction * 200.0
	Player.move_and_slide()
