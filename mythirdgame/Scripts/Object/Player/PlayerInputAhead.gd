# 类名
class_name PlayerInputAhead
extends Node

func _input_ahead(Player: CharacterBody2D, event: InputEvent) -> void:
	# 空中按下跳跃键，prepare_jump_timer计时器启动，0.5秒内落地，可直接起跳
	if event.is_action_pressed("Jump"):
		Player.prepare_jump_timer.start()
	# 跳跃高度减半（短按跳跃键）
	if not event.is_action_pressed("Jump") and Player.velocity.y < Player.jump_speed / 2:
		Player.velocity.y = Player.jump_speed / 2
	# 按下攻击键，并且可以连击
	if event.is_action_pressed("Attack") and Player.can_combo:
		Player.is_combo_requested = true
	else:
		Player.is_combo_requested = false
	# 空中按下滑铲键，prepare_slide_timer计时器启动，0.5秒内落地，可直接滑铲
	if event.is_action_pressed("Slide"):
		Player.prepare_slide_timer.start()
