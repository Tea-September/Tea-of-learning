extends Enemy

enum State {
	IDLE,
	WALK,
	RUNNING,
	HIT,
}
@onready var find: RayCast2D = $Graphic/Find
@onready var if_floor: RayCast2D = $Graphic/Floor
@onready var wall: RayCast2D = $Graphic/Wall
@onready var idle_timer: Timer = $IdleTimer

# 状态执行函数
func tick_physics(state: State, delta: float) -> void:
	match state:
		State.IDLE:
			move(0.0, delta)
		State.WALK:
			move(max_speed / 3, delta)
		State.RUNNING:
			if not if_floor.is_colliding() or wall.is_colliding():
				direction *= -1
			move(max_speed, delta)
		State.HIT:
			move(0.0, delta)

# 状态判断函数
func get_next_state(state: State) -> State:
	if find.is_colliding():
		idle_timer.start()
		return State.RUNNING
	match state:
		State.IDLE:
			if idle_timer.is_stopped():
				return State.WALK
		State.WALK:
			if not if_floor.is_colliding() or wall.is_colliding():
				return State.IDLE
		State.RUNNING:
			if idle_timer.is_stopped():
				return State.WALK
		State.HIT:
			pass
	return state

# 动画播放函数，只有在状态发送改变时调用
func transition_state(_from: State, to: State) -> void:
	if not State.IDLE or not State.IDLE:
		idle_timer.stop()
	match to:
		State.IDLE:
			idle_timer.start()
			animated.play("Idle")
			if wall.is_colliding():
				direction *= -1
		State.WALK:
			animated.play("Walk")
			if not if_floor.is_colliding():
				direction *= -1
				if_floor.force_raycast_update()
		State.RUNNING:
			idle_timer.start()
			animated.play("Run")
		State.HIT:
			animated.play("Hit")
