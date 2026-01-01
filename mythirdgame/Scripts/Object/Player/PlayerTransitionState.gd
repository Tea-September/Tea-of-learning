# 类名
class_name PlayerTransitionState
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

# 位于地面
const GROUND_STATES = [
	State.IDLE, State.RUNNING, State.LANDING, 
	State.ATTACK_1, State.ATTACK_2, State.ATTACK_3
]

# Called when the node enters the scene tree for the first time.
func _transition_state(Player: CharacterBody2D, from: State, to: State) -> void:
	# 当状态变化前不位于地面、变化后位于地面时coyote_timer停止
	if from not in GROUND_STATES and to in GROUND_STATES:
		Player.coyote_timer.stop()
	# 重置is_combo_requested
	Player.is_combo_requested = false
	match to:
		State.IDLE:
			Player.animated.play("Stand")
		State.RUNNING:
			Player.animated.play("Run")
		State.JUMP:
			Player.coyote_timer.stop()
			Player.prepare_jump_timer.stop() 
			Player.velocity.y = Player.jump_speed
			Player.animated.play("Jump")
		State.FALL:
			Player.animated.play("Fall")
			if from in GROUND_STATES:
				# 当走出地块时，coyote_timer计时器启动0.1秒内，可进行跳跃
				Player.coyote_timer.start()
		State.LANDING:
			Player.animated.play("Landing")
		State.SLIDINGWALL:
			Player.is_left_wall = Input.is_action_pressed("Left")
			Player.animated.play("SlidingWall")
		State.WALLJUMP:
			Player.prepare_jump_timer.stop()
			Player.velocity = Player.WALL_JUMP_VELOCITY
			Player.velocity.x *= Player.get_wall_normal().x
			Player.animated.play("Jump")
		State.ATTACK_1:
			# 攻击框开启
			$"../../../Graphics/HitBox/Attack1".disabled = false
			# 伤害
			Player.stats.attack = 1
			Player.animated.play("Attack1")
		State.ATTACK_2:
			# 攻击框开启
			$"../../../Graphics/HitBox/Attack2".disabled = false
			# 伤害
			Player.stats.attack = 2
			Player.animated.play("Attack2")
		State.ATTACK_3:
			# 攻击框开启
			$"../../../Graphics/HitBox/Attack3".disabled = false
			# 伤害
			Player.stats.attack = 3
			Player.animated.play("Attack3")
		State.HURT:
			# 血量减少
			Player.stats.health -= Player.pending_damage.amount
			# 获取方向，伤害来源的位置，指向自己（玩家）的位置
			var dir = Player.pending_damage.source.global_position.direction_to(Player.global_position)
			# 被击退
			Player.velocity = dir * Player.REPEL_AMOUNT
			# 受到攻击，关闭受击框，开启计时器
			Player.hurt_box.monitorable = false
			Player.invincible_timer.start()
			# 清空对象
			Player.pending_damage = null
			Player.animated.play("Hurt")
		State.DIE:
			Player.game_over = false
			$"../../../AnimationPlayer".play("Die")
		State.SLIDESTART:
			# 开始滑铲，关闭受击框
			Player.hurt_box.monitorable = false
			Player.animated.play("SlideStart")
		State.SLIDETACKLE:
			Player.animated.play("SlideTackle")
		State.UPSTANDING:
			# 滑铲结束，开启受击框
			Player.hurt_box.monitorable = true
			Player.animated.play("UpStanding")
	# 引擎速度减慢
	if to == State.WALLJUMP:
		Engine.time_scale = 0.5
	if from == State.WALLJUMP:
		Engine.time_scale = 1.0
	# 设置为第一帧
	Player.is_first_tick = true
