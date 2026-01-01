# 类名
class_name PlayerTickPhysics
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

func _tick_physics(Player: CharacterBody2D, state: State, delta: float) -> void:
	match state:
		State.IDLE:
			Player.move(Player.default_gravity, delta)
		State.RUNNING:
			Player.move(Player.default_gravity, delta)
		State.JUMP:
			# 跳跃第一帧无重力
			Player.move(0.0 if Player.is_first_tick else Player.default_gravity, delta)
		State.FALL:
			Player.move(Player.default_gravity, delta)
		State.LANDING:
			Player.move(Player.default_gravity, delta)
		State.SLIDINGWALL:
			# 滑墙时，下坠速度除5
			Player.move(Player.default_gravity / 5, delta)
		State.WALLJUMP:
			# 跳跃第一帧无重力
			Player.move(0.0 if Player.is_first_tick else Player.default_gravity, delta)
		State.HURT:
			Player.move(Player.default_gravity * 2, delta)
		State.DIE:
			Player.move(Player.default_gravity * 2, delta)
		State.SLIDESTART:
			Player.slide(Player.default_gravity, delta)
		State.SLIDETACKLE:
			Player.slide(Player.default_gravity, delta)
	# 结束第一帧
	Player.is_first_tick = false
