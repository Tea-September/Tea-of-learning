extends CharacterBody2D

@onready var Player: player = $".."

# Esc退出至标题页面
func _unhandled_input(event: InputEvent) -> void:
	# 按Esc，并且游戏未结束
	if event.is_action_pressed("ui_cancel") and not Player.is_game_over:
		# 游戏没有暂停
		if not get_tree( ).paused:
			# 暂停游戏
			Player._on_button_pressed()
		else:
			# 继续游戏
			Player._on_continue_pressed()
			# 阅读页面，使用Esc结束阅读
			if $"../../Plot".visible:
				$"../../Plot".visible = false
			if not Player.is_interactable:
				$"../../PlotPeople2".visible = false
				Player.is_interactable = true
