# 类名
class_name StateMachine
extends Node

# current_state初始值为-1
var  current_state : int = -1:
	# 当对current_state进行赋值时，会执行下面函数，T为要赋的值
	set(T):
		# 给根节点发送current_state的值和要改变的值，transition_state为用户自行定义的状态改变后的动画播放函数
		owner.transition_state(current_state, T)
		# 赋值
		current_state = T

# 最开始执行的函数
func _ready() -> void:
	# 等待根节点的ready信号，由于先初始化子节点的ready，根节点的ready还未初始化，所有不能使用owner，会导致报错
	await owner.ready
	# 重设current_state初始值
	current_state = 0

# 每一帧要执行的函数
func _physics_process(delta: float) -> void:
	while true:
		# 获取需要改变后的状态，以int形式保存，get_next_state为用户自行定义的获取需要改变状态函数
		var next_state = owner.get_next_state(current_state) as int
		# 状态未发生改变
		if next_state == current_state:
			break
		current_state = next_state
	# tick_physics用户自行定义的状态执行函数
	owner.tick_physics(current_state, delta)
