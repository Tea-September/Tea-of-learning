# 类名
class_name PlayerGetNextState
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

# 位于地面
const SLIDE_STATES = [
	State.SLIDESTART, State.SLIDETACKLE, State.UPSTANDING
]

func _get_next_state(Player: CharacterBody2D, state: State) -> State:
	# 交互按钮是否可见，取决于交互对象数组中，是否存在该对象
	Player.interacting.visible = not Player.interacting_with.is_empty()
	# 能量条恢复
	if Player.stats.energy < Player.stats.max_energy and not Player.if_energy:
		Player.energy_timer.start()
		Player.if_energy = true
	# 死亡
	if Player.stats.health <= 0:
		return State.DIE
	# 当处于非HURT状态时，才会进入HURT状态
	if Player.pending_damage:
		if state != State.HURT and Player.invincible_timer.time_left <= 0:
			return State.HURT
		Player.pending_damage = null
	# 获取左右的输入
	var movement = Input.get_axis("Left", "Right")
	# 滑墙限制1，需要顶部和底部都贴近墙面
	var is_sliding1 = Player.up_sliding_wall.is_colliding() and Player.down_sliding_wall.is_colliding()
	# 滑墙限制2，需要按住左或右方向键
	var is_sliding2 = Input.is_action_pressed("Left") or Input.is_action_pressed("Right")
	# （条件1）设置跳跃条件，按下跳跃键后，并且在地板上，或者coyote_timer计时器未结束<“走”出地块后的那一帧，也可以跳跃>
	var judgment_jump1 = (Player.is_on_floor() or Player.coyote_timer.time_left > 0) and Input.is_action_pressed("Jump")
	# （条件2）prepare_jump_timer计时未结束和在地板上<落地提前按下跳跃键跳跃>
	var judgment_jump2 = Player.prepare_jump_timer.time_left > 0 and Player.is_on_floor()
	# 二段跳状态恢复：在地面上
	if Player.is_on_floor():
		Player.double_jump = true
	# 二段跳执行条件：技能可执行、不在地面、按下跳跃键、体力大于1
	if Player.double_jump and not Player.is_on_floor() and Player.prepare_jump_timer.time_left > 0 and Player.stats.energy >= 1:
		Player.double_jump = false
		return State.JUMP
	# 跳跃，按空格松下后，再次按空格，才能跳跃
	if not Player.input_jump:
		if judgment_jump1 or judgment_jump2:
			return State.JUMP
	Player.input_jump = Input.is_action_pressed("Jump")
	# （条件1）设置滑铲条件，按下滑铲键后，并且在地板上
	var judgment_slide1 = (Player.is_on_floor() or Player.coyote_timer.time_left > 0) and Input.is_action_pressed("Slide")
	# （条件2）prepare_slide_timer计时未结束和在地板上<落地提前按下滑铲键滑铲>
	var judgment_slide2 = Player.prepare_slide_timer.time_left > 0 and Player.is_on_floor()
	# 滑铲，按滑铲键松下后，再次按滑铲键，才能滑铲
	if not Player.input_slide and state not in SLIDE_STATES and Player.stats.energy >= 1:
		if (judgment_slide1 or judgment_slide2) and not Player.down_sliding_wall.is_colliding():
			return State.SLIDESTART
	Player.input_slide = Input.is_action_pressed("Slide")
	# 判断是否站立不动
	var is_stand = not movement and not Player.velocity.x
	# 在地面时,并且没有地板，状态变化为FALL
	if state in GROUND_STATES and not Player.is_on_floor():
		return State.FALL
	# 无敌计时器
	if Player.invincible_timer.time_left > 0:
		# 进行闪烁
		Player.graphics.modulate.a = sin(Time.get_ticks_msec() / 20.0) * 0.5 + 0.5
	else:
		# 不进行闪烁
		Player.graphics.modulate.a = 1
		if state not in SLIDE_STATES:
			# 开启受击框
			Player.hurt_box.monitorable = true
	Player.can_combo = false
	match state:
		State.IDLE:
			# 玩家按下攻击键位，状态变化为ATTACK_1
			if Input.is_action_just_pressed("Attack"):
				return State.ATTACK_1
			# 发生移动时，状态变化为RUNNING
			if not is_stand:
				return State.RUNNING
		State.RUNNING:
			# 跑动音效
			if SoundManager.if_run and not SoundManager.run.playing:
				SoundManager.if_run = false
				SoundManager.play_sfx("Run")
			if SoundManager.run.playing:
				SoundManager.if_run = true
			# 玩家按下攻击键位，状态变化为ATTACK_1
			if Input.is_action_just_pressed("Attack"):
				return State.ATTACK_1
			# 未发生移动时，状态变化为IDLE
			if is_stand:
				return State.IDLE
		State.JUMP:
			# 下坠时，状态变化为FALL
			if Player.velocity.y >= 0:
				return State.FALL
		State.FALL:
			# 在地面时，状态变化为LANDING
			if Player.is_on_floor():
				return State.LANDING
			# 贴墙坠，状态变化为SLIDINGWALL
			if Player.is_on_wall() and is_sliding1 and is_sliding2:
				return State.SLIDINGWALL
		State.LANDING:
			# 移动状态，状态变化为RUNNING
			if not is_stand:
				return State.RUNNING
			# 着陆动画播放完毕，状态变化为IDLE
			if not Player.animated.is_playing():
				return State.IDLE
		State.SLIDINGWALL:
			# 蹬墙跳，并且不是第一帧
			if Player.prepare_jump_timer.time_left > 0 and not Player.is_first_tick:
				if Player.is_left_wall:
					if Input.is_action_pressed("Right"):
						return State.WALLJUMP
				else:
					if Input.is_action_pressed("Left"):
						return State.WALLJUMP
			# 在地面时，状态变化为LANDING
			if Player.is_on_floor():
				return State.LANDING
			# 不贴墙或者没有按住左右键时，状态变化为FALL
			if not Player.is_on_wall() or not (Input.is_action_pressed("Left") or Input.is_action_pressed("Right")):
				return State.FALL
		State.WALLJUMP:
			# 贴墙坠，状态变化为SLIDINGWALL，并且不是第一帧
			if Player.is_on_wall() and is_sliding1 and is_sliding2 and not Player.is_first_tick:
				return State.SLIDINGWALL
			# 下坠时，状态变化为FALL
			if Player.velocity.y >= 0:
				return State.FALL
		State.ATTACK_1:
			# 可以连击
			Player.can_combo = true
			# 动画播放完毕，进入IDLE状态
			if not Player.animated.is_playing():
				# 攻击框关闭
				$"../../../Graphics/HitBox/Attack1".disabled = true
				if Player.is_combo_requested:
					return State.ATTACK_2
				else:
					return State.IDLE
		State.ATTACK_2:
			# 可以连击
			Player.can_combo = true
			# 动画播放完毕，进入IDLE状态
			if not Player.animated.is_playing():
				# 攻击框关闭
				$"../../../Graphics/HitBox/Attack2".disabled = true
				if Player.is_combo_requested:
					return State.ATTACK_3
				else:
					return State.IDLE
		State.ATTACK_3:
			# 动画播放完毕，进入IDLE状态
			if not Player.animated.is_playing():
				# 攻击框关闭
				$"../../../Graphics/HitBox/Attack3".disabled = true
				return State.IDLE
		State.HURT:
			# 动画播放完毕，进入IDLE状态
			if not Player.animated.is_playing():
				return State.IDLE
		State.SLIDESTART:
			# 动画播放完毕，进入SLIDETACKLE状态
			if not Player.animated.is_playing():
				return State.SLIDETACKLE
			# 靠近墙面，进入UPSTANDING状态
			if Player.down_sliding_wall.is_colliding():
				return State.UPSTANDING
		State.SLIDETACKLE:
			# 动画播放完毕 or 靠近墙面，进入UPSTANDING状态
			if Player.prepare_slide_timer.time_left == 0 or Player.down_sliding_wall.is_colliding():
				return State.UPSTANDING
		State.UPSTANDING:
			# 动画播放完毕，进入SLIDETACKLE状态
			if not Player.animated.is_playing():
				return State.IDLE
	return state
